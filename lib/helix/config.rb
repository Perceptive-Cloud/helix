require 'helix/video'
require 'helix/track'
require 'helix/album'
require 'helix/image'

module Helix

  class Config

    unless defined?(self::DEFAULT_FILENAME)
      DEFAULT_FILENAME = './helix.yml'
      SCOPES           = %w(reseller company library)
      VALID_SIG_TYPES  = [ :ingest, :update, :view ]
    end

    attr_accessor :credentials

    def initialize(yaml_file_location = DEFAULT_FILENAME)
      @filename    = yaml_file_location
      @credentials = YAML.load(File.open(@filename))
    end

    ### MEDIA TYPES
    def album
      @album ||= Helix::Album.new(config: self)
    end

    def image
      @image ||= Helix::Image.new(config: self)
    end

    def track
      @track ||= Helix::Track.new(config: self)
    end

    def video
      @video ||= Helix::Video.new(config: self)
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
    # @param [String] base_url the base part of the URL to be used
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
    # @example 
    #   Helix::Video.signature(:ingest)
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
