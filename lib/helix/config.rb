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
      SCOPES           = %w(reseller company library)
      SIG_DURATION     = 1200 # in minutes
      TIME_OFFSET      = 1000 * 60 # 1000 minutes, lower to give some margin of error
      VALID_SIG_TYPES  = [ :ingest, :update, :view ]
    end

    attr_accessor :credentials
    attr_reader   :signature_for, :signature_expiration_for

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
      config.instance_variable_set(:@filename,    yaml_file_location)
      config.instance_variable_set(:@credentials, YAML.load(File.open(yaml_file_location)))
      config
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def add_sub_urls(base_url, opts)
      guid, action = [:guid, :action].map { |sub| opts[sub] }
      url   = "#{base_url}/#{opts[:media_type]}"
      url  += "/#{guid}"   if guid
      url  += "/#{action}" if action
      "#{url}.#{opts[:format]}"
    end

    # Creates a full RESTful URL to be used for HTTP requests.
    #
    # @param [Hash] opts a hash of options for building URL
    # @return [String] The full RESTful URL string object
    def build_url(opts={})
      opts[:format]     ||= :json
      opts[:media_type] ||= :videos
      base_url = get_base_url(opts)
      url      = add_sub_urls(base_url, opts)
    end

    def clear_signatures!
      @signature_for            = {}
      @signature_expiration_for = {}
    end

    # Creates the base url with information collected from credentials.
    #
    # @param [Hash] opts a hash of options for building URL
    # @return [String] The base RESTful URL string object
    def get_base_url(opts)
      creds     = credentials
      base_url  = creds['site']
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
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def get_response(url, opts={})
      sig_type    = opts.delete(:sig_type)
      params      = opts.merge(signature: signature(sig_type, opts))
      response    = RestClient.get(url, params: params)
      parse_response_by_url_format(response, url)
    end

    # Fetches the signature for a specific license key.
    #
    # @param [Symbol] sig_type The type of signature required for calls.
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
      @signature_for[lk][sig_type] = RestClient.get(url_for(sig_type, opts))
    end

    private

    def error_message_for(sig_type)
      "I don't understand '#{sig_type}'. Please give me one of :ingest, :update, or :view."
    end

    def existing_sig_for(sig_type)
      return if sig_expired_for?(sig_type)
      @signature_for[license_key][sig_type]
    end

    def license_key
      @credentials['license_key']
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
      contributor, library_id = [:contributor, :library_id].map { |key| opts[key] }
      url  = "#{credentials['site']}/api/#{sig_type}_key?licenseKey=#{credentials['license_key']}&duration=#{SIG_DURATION}"
      url += "&contributor=#{contributor}"  if contributor
      url += "&library_id=#{library_id}"    if library_id
      url
    end

  end

end
