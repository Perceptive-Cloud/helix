require 'rest_client'
require 'json'
require 'yaml'

module Helix
  class Base

    unless defined?(self::METHODS_DELEGATED_TO_CLASS)
      METHODS_DELEGATED_TO_CLASS = [ :guid_name, :media_type_sym, :plural_media_type ]
    end

    attr_accessor :attributes, :config

    def self.create(attributes={})
      url       = config.build_url(action: :create_many, media_type: plural_media_type)
      response  = RestClient.post(url, attributes.merge(signature: config.signature(:ingest)))
      attrs     = JSON.parse(response)
      self.new({attributes: attrs[media_type_sym]})
    end

    def find(guid)
      self.attributes          ||= {}
      self.attributes[guid_name] = guid
      self.load
    end

    def find_all(opts)
      url          = config.build_url(format: :json)
      raw_response = config.get_response(url, opts.merge(sig_type: :view))
      data_sets    = raw_response[plural_media_type]
      return [] if data_sets.nil?
      data_sets.map { |attrs| self.class.new(attributes: attrs) }
    end

    def self.guid_name
      "#{self.media_type_sym}_id"
    end

    def self.plural_media_type
      "#{self.media_type_sym}s"
    end

    METHODS_DELEGATED_TO_CLASS.each do |meth|
      define_method(meth) { |*args| self.class.send(meth, *args) }
    end

    def initialize(opts)
      @attributes = opts[:attributes]
      @config     = opts[:config]
    end

    def destroy
      url = config.build_url(format: :xml, guid: guid, media_type: plural_media_type)
      RestClient.delete(url, params: {signature: config.signature(:update)})
    end

    def guid
      @attributes[guid_name]
    end

    def load(opts={})
      url         = config.build_url(format: :json, guid: self.guid, media_type: plural_media_type)
      raw_attrs   = config.get_response(url, opts.merge(sig_type: :view))
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
      url    = config.build_url(format: :xml, guid: guid, media_type: plural_media_type)
      params = {signature: config.signature(:update)}.merge(media_type_sym => opts)
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
