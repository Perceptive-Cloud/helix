require 'rest_client'
require 'json'
require 'yaml'

module Helix
  class Base

    unless defined?(self::CREDENTIALS)
      FILENAME    = './helix.yml'
      CREDENTIALS = YAML.load(File.open(FILENAME))
    end

    attr_accessor :attributes

    def self.create(attributes={})
      url       = self.build_url( action:     :create_many,
                                  media_type: plural_media_type)
      response  = RestClient.post(url, attributes.merge(signature: signature))
      attrs     = JSON.parse(response)
      self.new({attributes: attrs[media_type_sym]})
    end

    def self.build_url(opts={})
      opts[:format]     ||= :json
      opts[:media_type] ||= :videos
      base_url  = CREDENTIALS['site']
      base_url += "/resellers/#{CREDENTIALS['reseller']}" if CREDENTIALS['reseller']
      if CREDENTIALS['company']
        base_url += "/companies/#{CREDENTIALS['company']}"
        base_url += "/libraries/#{CREDENTIALS['library']}" if CREDENTIALS['library']
      end
      url   = "#{base_url}/#{opts[:media_type]}"
      url  += "/#{opts[:guid]}"   if opts[:guid]
      url  += "/#{opts[:action]}" if opts[:action]
      "#{url}.#{opts[:format]}"
    end

    def destroy
      url = Helix::Base.build_url(media_type: plural_media_type,
                                  guid:       self.guid,
                                  format:     :xml)
      RestClient.delete(url, params: {signature: signature})
    end

    def self.find(guid)
      item = self.new(attributes: { guid_name => guid })
      item.load
    end

    def self.get_response(url, opts={})
      params      = opts.merge(signature: signature)
      response    = RestClient.get(url, params: params)
      JSON.parse(response)
    end

    def self.find_all(opts)
      url          = self.build_url(format: :json)
      raw_response = self.get_response(url, opts)
      data_sets    = raw_response[plural_media_type]
      return [] if data_sets.nil?
      data_sets.map { |attrs| self.new(attributes: attrs) }
    end

    # TODO: messy near-duplication. Clean up.
    def self.signature
      self.new({}).signature
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
      raw_attrs   = Helix::Base.get_response(url, opts)
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

    def signature
      # TODO: Memoize (if it's valid)
      # TODO: read vs. read/write
      url = "#{CREDENTIALS['site']}/api/update_key?licenseKey=#{CREDENTIALS['license_key']}&duration=1200"
      # FIXME: Replace Net::HTTP with our own connection abstraction
      @signature = Net::HTTP.get_response(URI.parse(url)).body
    end

    def update(opts={})
      url    = Helix::Base.build_url(format: :xml, guid: guid, media_type: plural_media_type)
      params = {signature: signature}.merge(media_type_sym => opts)
      RestClient.put(url, params)
      self
    end

    private

    def guid_name;         "#{media_type_sym}_id"; end
    def plural_media_type; "#{media_type_sym}s";   end

    def massage_raw_attrs(raw_attrs)
      # TODO: Albums JSON output is embedded as the only member of an Array.
      proper_hash = raw_attrs.respond_to?(:has_key?) && raw_attrs.has_key?(guid_name)
      proper_hash ? raw_attrs : raw_attrs.first
    end

  end
end
