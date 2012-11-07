require 'rest_client'
require 'json'
require 'yaml'

module Helix
  class Base

    unless defined?(self::VALID_SIG_TYPES)
      DEFAULT_FILENAME = './helix.yml'
      METHODS_DELEGATED_TO_CLASS = [ :guid_name, :media_type_sym, :plural_media_type, :signature ]
      SCOPES          = %w(reseller company library)
      VALID_SIG_TYPES = [ :ingest, :update, :view ]
    end

    attr_accessor :attributes

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The end portion of the RESTful URL string object
    def self.add_sub_urls(base_url, opts)
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
    def self.build_url(opts={})
      opts[:format]     ||= :json
      opts[:media_type] ||= :videos
      base_url = self.get_base_url(opts)
      url      = self.add_sub_urls(base_url, opts)
    end

    # Class level configuration settings, allows specification of yaml
    # file that is not helix.yml.
    #
    # Example:
    # Helix::Base.config("/home/my_new_yaml.yml")
    #
    # @param [String] yaml_file_location the location and name for the YAML config file.
    def self.config(yaml_file_location = DEFAULT_FILENAME)
      @@filename    = yaml_file_location
      @@credentials = YAML.load(File.open(@@filename))
    end

    # Creates a new record via API and then returns an instance of that record.
    # 
    # Example is using Video class since Video inherits from Base. This won't
    # normally be called as Helix::Base.create
    #
    # Example:
    # Helix::Video.create({title: "My new video"})
    #
    # @param [Hash] attributes a hash containing the attributes used in the create
    # @return [Helix::Base] An instance of Helix::Base  
    def self.create(attributes={})
      url       = self.build_url( action:     :create_many,
                                  media_type: plural_media_type)
      response  = RestClient.post(url, attributes.merge(signature: signature(:ingest)))
      attrs     = JSON.parse(response)
      self.new({attributes: attrs[media_type_sym]})
    end

    # Getter for credentials.
    #
    # @return [Hash] Credential information. 
    def self.credentials
      @@credentials
    end

    # Setter for credentials.
    # (see .credentials)
    def self.credentials=(new_creds)
      @@credentials = new_creds
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def self.find(guid)
      item = self.new(attributes: { guid_name => guid })
      item.load
    end

    # Fetches all accessible records, places them into instances, and returns
    # them as an array.
    #
    # Example:
    # Helix::Video.find_all #=> [video1,video2]
    #
    # @param [Hash] opts a hash of options for parameters passed into the HTTP GET
    # @return [Array] The array of instance objects for a class.
    def self.find_all(opts)
      url          = self.build_url(format: :json)
      raw_response = self.get_response(url, opts.merge(sig_type: :view))
      data_sets    = raw_response[plural_media_type]
      return [] if data_sets.nil?
      data_sets.map { |attrs| self.new(attributes: attrs) }
    end

    # Creates the base url with information collected from credentials.
    #
    # @param [Hash] opts a hash of options for building URL
    # @return [String] The base RESTful URL string object
    def self.get_base_url(opts)
      base_url  = self.credentials['site']
      reseller, company, library = SCOPES.map do |scope|
        self.credentials[scope]
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
    def self.get_response(url, opts={})
      sig_type    = opts.delete(:sig_type)
      params      = opts.merge(signature: signature(sig_type))
      response    = RestClient.get(url, params: params)
      JSON.parse(response)
    end

    # Creates a string that associates to the class id.
    #
    # Example:
    # Helix::Video.guid_name #=> "video_id" 
    #
    # @return [String] The full RESTful URL string object
    def self.guid_name
      "#{self.media_type_sym}_id"
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def self.plural_media_type
      "#{self.media_type_sym}s"
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def self.signature(sig_type)
      # OPTIMIZE: Memoize (if it's valid)
      unless VALID_SIG_TYPES.include?(sig_type)
        raise ArgumentError, "I don't understand '#{sig_type}'. Please give me one of :ingest, :update, or :view."
      end

      url = "#{self.credentials['site']}/api/#{sig_type}_key?licenseKey=#{self.credentials['license_key']}&duration=1200"
      @signature = RestClient.get(url)
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    METHODS_DELEGATED_TO_CLASS.each do |meth|
      define_method(meth) { |*args| self.class.send(meth, *args) }
    end

    # Deletes the record of the Helix::Base instance.
    #
    # Example:
    # video = Helix::Video.create({title: "Some Title"})
    # video.destroy
    #
    # @return [String] The response from the HTTP DELETE call.
    def destroy
      url = Helix::Base.build_url(media_type: plural_media_type,
                                  guid:       self.guid,
                                  format:     :xml)
      RestClient.delete(url, params: {signature: signature(:update)})
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def guid
      @attributes[guid_name]
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def initialize(opts)
      @attributes = opts[:attributes]
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def load(opts={})
      url         = Helix::Base.build_url(format:     :json,
                                          guid:       self.guid,
                                          media_type: plural_media_type)
      raw_attrs   = Helix::Base.get_response(url, opts.merge(sig_type: :view))
      @attributes = massage_raw_attrs(raw_attrs)
      self
    end
    alias_method :reload, :load

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def method_missing(method_sym)
      begin
        @attributes[method_sym.to_s]
      rescue
        raise NoMethodError, "#{method_sym} is not recognized within #{self.class.to_s}'s @attributes"
      end
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def update(opts={})
      url    = Helix::Base.build_url(format: :xml, guid: guid, media_type: plural_media_type)
      params = {signature: signature(:update)}.merge(media_type_sym => opts)
      RestClient.put(url, params)
      self
    end

    private

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def massage_raw_attrs(raw_attrs)
      # FIXME: Albums JSON output is embedded as the only member of an Array.
      proper_hash = raw_attrs.respond_to?(:has_key?) && raw_attrs.has_key?(guid_name)
      proper_hash ? raw_attrs : raw_attrs.first
    end

  end
end
