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
      self.new(attributes: attributes)
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
      url = Helix::Base.build_url(media_type: plural_media_type)
      RestClient.delete(url)
      nil
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
                                          guid:       guid,
                                          media_type: plural_media_type)
      @attributes = Helix::Base.get_response(url, opts)
      self
    end
    alias_method :reload, :load

    def method_missing(method_sym)
      @attributes[method_sym.to_s]
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

  end
end
