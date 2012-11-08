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
      VALID_SIG_TYPES  = [ :ingest, :update, :view ]
    end

    attr_accessor :credentials

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

    # Creates the base url with information collected from credentials.
    #
    # @param [Hash] opts a hash of options for building URL
    # @return [String] The base RESTful URL string object
    def get_base_url(opts)
      base_url  = credentials['site']
      reseller, company, library = SCOPES.map do |scope|
        credentials[scope]
      end
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
      params      = opts.merge(signature: signature(sig_type))
      response    = RestClient.get(url, params: params)
      JSON.parse(response)
    end

    # Fetches the signature for a specific license key.
    #
    # @param [Symbol] sig_type The type of signature required for calls.
    # @return [String] The signature needed to pass around for calls.
    def signature(sig_type)
      # OPTIMIZE: Memoize (if it's valid)
      unless VALID_SIG_TYPES.include?(sig_type)
        raise ArgumentError, "I don't understand '#{sig_type}'. Please give me one of :ingest, :update, or :view."
      end

      url = "#{credentials['site']}/api/#{sig_type}_key?licenseKey=#{credentials['license_key']}&duration=1200"
      @signature = RestClient.get(url)
    end

  end

end
