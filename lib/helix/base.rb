require 'rest_client'
require 'json'
require 'yaml'

module Helix
  class Base

    unless defined?(self::CREDENTIALS)
      FILENAME    = './helix.yml'
      CREDENTIALS = YAML.load(File.open(FILENAME))
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
    # @return [String] The full RESTful URL string object
    def self.add_sub_urls(base_url, opts)
      guid, action = [:guid, :action].map { |sub| opts[sub] }
      url   = "#{base_url}/#{opts[:media_type]}"
      url  += "/#{guid}"   if guid
      url  += "/#{action}" if action
      "#{url}.#{opts[:format]}"
    end

    def self.build_url(opts={})
      opts[:format]     ||= :json
      opts[:media_type] ||= :videos
      base_url = self.get_base_url(opts)
      url      = self.add_sub_urls(base_url, opts)
    end

    def self.create(attributes={})
      url       = self.build_url( action:     :create_many,
                                  media_type: plural_media_type)
      response  = RestClient.post(url, attributes.merge(signature: signature(:ingest)))
      attrs     = JSON.parse(response)
      self.new({attributes: attrs[media_type_sym]})
    end

    def self.find(guid)
      item = self.new(attributes: { guid_name => guid })
      item.load
    end

    def self.find_all(opts)
      url          = self.build_url(format: :json)
      raw_response = self.get_response(url, opts.merge(sig_type: :view))
      data_sets    = raw_response[plural_media_type]
      return [] if data_sets.nil?
      data_sets.map { |attrs| self.new(attributes: attrs) }
    end

    def self.get_base_url(opts)
      base_url  = Helix::Base::CREDENTIALS['site']
      reseller, company, library = SCOPES.map do |scope|
        Helix::Base::CREDENTIALS[scope]
      end
      base_url += "/resellers/#{reseller}" if reseller
      if company
        base_url += "/companies/#{company}"
        base_url += "/libraries/#{library}" if library
      end
      base_url
    end

    def self.get_response(url, opts={})
      sig_type    = opts.delete(:sig_type)
      params      = opts.merge(signature: signature(sig_type))
      response    = RestClient.get(url, params: params)
      JSON.parse(response)
    end

    def self.guid_name
      "#{self.media_type_sym}_id"
    end

    def self.plural_media_type
      "#{self.media_type_sym}s"
    end

    def self.signature(sig_type)
      # OPTIMIZE: Memoize (if it's valid)
      unless VALID_SIG_TYPES.include?(sig_type)
        raise ArgumentError, "I don't understand '#{sig_type}'. Please give me one of :ingest, :update, or :view."
      end

      url = "#{CREDENTIALS['site']}/api/#{sig_type}_key?licenseKey=#{CREDENTIALS['license_key']}&duration=1200"
      @signature = RestClient.get(url)
    end

    METHODS_DELEGATED_TO_CLASS.each do |meth|
      define_method(meth) { |*args| self.class.send(meth, *args) }
    end

    def destroy
      url = Helix::Base.build_url(media_type: plural_media_type,
                                  guid:       self.guid,
                                  format:     :xml)
      RestClient.delete(url, params: {signature: signature(:update)})
    end

    def guid
      @attributes[guid_name]
    end

    def initialize(opts)
      @attributes = opts[:attributes]
    end

    def load(opts={})
      url         = Helix::Base.build_url(format:     :json,
                                          guid:       self.guid,
                                          media_type: plural_media_type)
      raw_attrs   = Helix::Base.get_response(url, opts.merge(sig_type: :view))
      @attributes = massage_raw_attrs(raw_attrs)
      self
    end
    alias_method :reload, :load

    def method_missing(method_sym)
      begin
        @attributes[method_sym.to_s]
      rescue
        raise NoMethodError, "#{method_sym} is not recognized within #{self.class.to_s}'s @attributes"
      end
    end

    def update(opts={})
      url    = Helix::Base.build_url(format: :xml, guid: guid, media_type: plural_media_type)
      params = {signature: signature(:update)}.merge(media_type_sym => opts)
      RestClient.put(url, params)
      self
    end

    private

    def massage_raw_attrs(raw_attrs)
      # FIXME: Albums JSON output is embedded as the only member of an Array.
      proper_hash = raw_attrs.respond_to?(:has_key?) && raw_attrs.has_key?(guid_name)
      proper_hash ? raw_attrs : raw_attrs.first
    end

  end
end
