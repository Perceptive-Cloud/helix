require 'helix/video'
require 'helix/track'
require 'helix/album'
require 'helix/image'
require 'singleton'

module Helix

  class Config

    include Singleton

    unless defined?(self::DEFAULT_FILENAME)
      DEFAULT_FILENAME = './helix.yml'
      ITEMS_PER_PAGE   = 100
      SCOPES           = [:reseller, :company, :library]
      SIG_DURATION     = 1200 # in minutes
      STARTING_PAGE    = 1
      TIME_OFFSET      = 1000 * 60 # 1000 minutes, lower to give some margin of error
      VALID_SIG_TYPES  = [ :ingest, :update, :view ]
    end

    attr_accessor :credentials
    attr_reader   :response, :signature_for, :signature_expiration_for

    # Creates a singleton of itself, setting the config
    # to a specified YAML file. If no file is specified the default
    # helix.yml file is used.
    #
    # @example
    #   Helix::Config.load("/some/path/my_yaml.yml")
    #   video = Helix::Video.find("8e0701c142ab1") #Uses my_yaml.yml
    #
    # @param [String] yaml_file_location the yaml file used for config
    # @return [Helix::Config] config returns singleton of Helix::Config
    def self.load(yaml_file_location = DEFAULT_FILENAME)
      config = self.instance
      config.instance_variable_set(:@filename, yaml_file_location)
      creds = YAML.load(File.open(yaml_file_location)).symbolize_keys
      config.instance_variable_set(:@credentials, creds)
      RestClient.proxy = config.proxy
      config
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def add_sub_urls(base_url, opts)
      guid, action, format = [:guid, :action, :formats].map { |sub| opts[sub] }
      url   = sub_url_scoping(base_url, opts)
      url  += "/#{guid}"            if guid
      url  += "/formats/#{format}"  if format
      url  += "/#{action}"          if action
      return url if opts[:content_type].blank?
      "#{url}.#{opts[:content_type]}"
    end

    # Creates a full RESTful URL to be used for HTTP requests.
    #
    # @param [Hash] opts a hash of options for building URL
    # @return [String] The full RESTful URL string object
    def build_url(opts={})
      opts[:content_type]   ||= :xml
      opts[:resource_label] ||= :videos
      base_url                = get_base_url(opts)
      url                     = add_sub_urls(base_url, opts)
    end

    def clear_signatures!
      @signature_for            = {}
      @signature_expiration_for = {}
    end

    # Makes aggregated calls to get_response with pagination
    # folding/injecting/accumulating the results into a single output set.
    #
    # @param [String] url the base part of the URL to be used
    # @param [String] plural_resource_label: "videos", "tracks", etc.
    # @param [Hash] original_opts a hash of options for building URL additions
    # @return [Array] The accumulated attribute Hashes for ORM instances
    def get_aggregated_data_sets(url, plural_resource_label, original_opts={})
      data_sets, page, per_page = [], STARTING_PAGE
      begin
        aggregation_opts = {page: page, per_page: ITEMS_PER_PAGE}.merge(original_opts)
        raw_response = get_response(url, {sig_type: :view}.merge(aggregation_opts))
        data_set     = raw_response[plural_resource_label]
        data_sets   += data_set if data_set
        page        += 1
      end until last_page?
      data_sets
    end

    # Creates the base url with information collected from credentials.
    #
    # @param [Hash] opts a hash of options for building URL
    # @return [String] The base RESTful URL string object
    def get_base_url(opts)
      creds     = credentials
      base_url  = creds[:site]
      return base_url if opts[:guid] || opts[:action] == :create_many
      reseller, company, library = SCOPES.map { |scope| creds[scope] }
      base_url += "/resellers/#{reseller}" if reseller
      if company
        base_url += "/companies/#{company}"
        base_url += "/libraries/#{library}" if library
      end
      base_url
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] url the base part of the URL to be used
    # @param [Hash] original_opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def get_response(url, original_opts={})
      opts        = massage_custom_fields_in(original_opts)
      sig_type    = opts.delete(:sig_type)
      params      = opts.merge(signature: signature(sig_type, opts))
      begin
        @response = RestClient.get(url, params: params)
      rescue RestClient::InternalServerError => e
        raise NetworkError, "Unable to access url #{url} with params #{params}"
      end
      parse_response_by_url_format(@response, url)
    end

    # Reports whether the most recent response's headers have a true :is_last_page value
    #
    # @return [Boolean] As above. Returns false if no such header is found,
    # or if there is an explictly false value.
    def last_page?
      return false unless @response
      return false unless @response.headers
      return true  unless @response.headers.has_key?(:is_last_page)
      @response.headers[:is_last_page] == "true"
    end

    # Fetches the signature for a specific license key.
    #
    # @param [Symbol] sig_type The type of signature required for calls.
    # @param [Hash] opts allows you to overide contributor and license_id
    # @return [String] The signature needed to pass around for calls.
    def signature(sig_type, opts={})
      prepare_signature_memoization
      memo_sig = existing_sig_for(sig_type)
      return memo_sig if memo_sig
      unless VALID_SIG_TYPES.include?(sig_type)
        raise ArgumentError, error_message_for(sig_type)
      end

      lk = license_key
      @signature_expiration_for[lk][sig_type] = Time.now + TIME_OFFSET
      new_sig_url                  = url_for(sig_type, opts)
      @signature_for[lk][sig_type] = RestClient.get(new_sig_url)
    end

    def proxy
      if @credentials[:proxy_uri]
        protocol, uri = @credentials[:proxy_uri].split "://"
        user, pass    = @credentials[:proxy_username], @credentials[:proxy_password]
        proxy_str     = "#{protocol}://"
        proxy_str    += "#{user}:"  if user
        proxy_str    += "#{pass}"   if user && pass
        proxy_str    += '@'         if user
        proxy_str    += "#{uri}"
      elsif @credentials[:proxy_used] == true
        ENV['http_proxy']
      end
    end

    private

    def sub_url_scoping(base_url, opts)
      resource_label = opts[:resource_label]
      if resource_label == 'libraries'
        co_id = opts[:company] || credentials[:company]
        raise "No company to scope to: #{credentials}" if co_id.nil?
        resource_label = "companies/#{co_id}/libraries"
      end
      "#{base_url}/#{resource_label}"
    end

    def error_message_for(sig_type)
      "I don't understand '#{sig_type}'. Please give me one of :ingest, :update, or :view."
    end

    def existing_sig_for(sig_type)
      return if sig_expired_for?(sig_type)
      @signature_for[license_key][sig_type]
    end

    def get_contributor_library_company(opts)
      sig_param_labels = [:contributor, :library, :company]
      scoping_proc     = lambda { |key| opts[key] || credentials[key] }
      contributor, library, company = sig_param_labels.map(&scoping_proc)
      contributor    ||= 'helix_default_contributor'
      [contributor, library, company]
    end

    def license_key
      @credentials[:license_key]
    end

    def massage_custom_fields_in(opts)
      return opts.clone unless opts.has_key?(:custom_fields)
      cf_opts = opts.delete(:custom_fields)
      cf_opts.inject(opts.clone) do |memo,pair|
        k,v = pair
        memo.merge("custom_fields[#{k}]" => v)
      end
    end

    def parse_response_by_url_format(response, url)
      ### FIXME: This is ugly. Clean it up.
      if url =~ /json/
        JSON.parse(response)
      elsif url =~ /xml/
        #TODO: Cleanup Nori and response gsub.
        Nori.parser = :nokogiri
        xml = response.gsub(/<custom-fields type='array'>/, '<custom-fields type=\'hash\'>')
        Nori.parse(xml)
      elsif url =~ /csv/
        response
      else
        raise "Could not parse #{url}"
      end
    end

    def prepare_signature_memoization
      lk = license_key
      @signature_for                ||= {}
      @signature_expiration_for     ||= {}
      @signature_for[lk]            ||= {}
      @signature_expiration_for[lk] ||= {}
    end

    def sig_expired_for?(sig_type)
      expires_at = @signature_expiration_for[license_key][sig_type]
      return true if expires_at.nil?
      expires_at <= Time.now
    end

    def url_for(sig_type, opts={})
      contributor, library, company = get_contributor_library_company(opts)
      url  = "#{credentials[:site]}/api/#{sig_type}_key?"
      url += "licenseKey=#{credentials[:license_key]}&duration=#{SIG_DURATION}"
      url += "&contributor=#{contributor}" if sig_type == :ingest
      url += "&library_id=#{library}"   if library
      url += "&company_id=#{company}"   if company
      url
    end

  end

end
