require 'helix/video'
require 'helix/track'
require 'helix/album'
require 'helix/image'
require 'helix/builds_urls'
require 'helix/has_signatures'
require 'singleton'

module Helix

  class Config

    include BuildsUrls
    include HasSignatures
    include Singleton

    unless defined?(self::DEFAULT_FILENAME)
      DEFAULT_FILENAME = './helix.yml'
      ITEMS_PER_PAGE   = 100
      STARTING_PAGE    = 1
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

  end

end
