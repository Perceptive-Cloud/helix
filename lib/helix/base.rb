require 'rest-client'
require 'json'
require 'yaml'
require 'nori'
require 'time'

module Helix
  class Base

    unless defined?(self::METHODS_DELEGATED_TO_CLASS)
      METHODS_DELEGATED_TO_CLASS = [ :guid_name, :media_type_sym, :plural_media_type ]
    end

    attr_accessor :attributes
    attr_writer   :config

    # Fetches all accessible records, places them into instances, and returns
    # them as an array.
    #
    # @example
    #   Helix::Video.find_all(query: 'string_to_match') #=> [video1,video2]
    #
    # @param [Hash] opts a hash of options for parameters passed into the HTTP GET
    # @return [Array] The array of instance objects for a class.
    def self.find_all(opts={})
      data_sets = get_data_sets(opts)
      return [] if data_sets.nil?
      data_sets.map { |attrs| self.new( attributes: massage_attrs(attrs),
                                        config:     config) }
    end

    def self.where(opts={})
      find_all(opts)
    end

    def self.all
      find_all
    end

    def self.get_data_sets(opts)
      url          = config.build_url(content_type: opts[:content_type] || :xml,
                                      media_type:   self.plural_media_type)
      # We allow opts[:sig_type] for internal negative testing only.
      raw_response = config.get_response(url, {sig_type: :view}.merge(opts))
      data_sets    = raw_response[plural_media_type]
    end

    # Creates a string that associates to the class id.
    #
    # @example
    #   Helix::Video.guid_name #=> "video_id"
    #
    # @return [String] The guid name for a specific class.
    def self.guid_name
      "#{self.media_type_sym}_id"
    end

    # Creates a string associated with a class name pluralized
    #
    # @example
    #   Helix::Video.plural_media_type #=> "videos"
    #
    # @return [String] The class name pluralized
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

    def self.config
      Helix::Config.instance
    end

    def config
      @config ||= Helix::Config.instance
    end

    # Creates a string that associates to the class id.
    #
    # @example
    #   video = Helix::Video.create({title: "My new title"})
    #   video.guid #=> "9e0989v234sf4"
    #
    # @return [String] The guid for the class instance.
    def guid
      @attributes[guid_name]
    end

    # Loads in the record from a HTTP GET response.
    #
    # @param [Hash] opts a hash of attributes to update the instance with.
    # @return [Base] Returns an instance of the class.
    def load(opts={})
      memo_cfg    = config
      url         = memo_cfg.build_url(content_type: :json, guid: self.guid, media_type: plural_media_type)
      # We allow opts[:sig_type] for internal negative testing only.
      raw_attrs   = memo_cfg.get_response(url, {sig_type: :view}.merge(opts))
      @attributes = massage_raw_attrs(raw_attrs)
      self
    end
    alias_method :reload, :load

    # Raises an error for missing method calls.
    #
    # @param [Symbol] method_sym The method attempting to be called.
    # @return [String] An error for the method attempting to be called.
    def method_missing(method_sym)
      begin
        @attributes[method_sym.to_s]
      rescue
        raise NoMethodError, "#{method_sym} is not recognized within #{self.class.to_s}'s @attributes"
      end
    end

    private

    def massage_raw_attrs(raw_attrs)
      # FIXME: Albums JSON output is embedded as the only member of an Array.
      proper_hash = raw_attrs.respond_to?(:has_key?) && raw_attrs.has_key?(guid_name)
      proper_hash ? raw_attrs : raw_attrs.first
    end

    def self.massage_attrs(attrs)
      return attrs unless attrs.is_a?(Hash)
      Hash[massage_custom_field_attrs(massage_time_attrs(attrs)).sort]
    end

    def self.massage_time_attrs(attrs)
      return attrs unless attrs.is_a?(Hash)
      attrs.each do |key, val|
        begin
          if val.is_a?(String) && val =~ /(\d{4}-\d{2}-\d{2})/
            attrs[key] = Time.parse(val)
          end
        rescue ArgumentError,RangeError;end
        massage_time_attrs(val)
      end
    end

    def self.massage_custom_field_attrs(attrs)
      return attrs unless attrs.is_a?(Hash)
      return attrs unless attrs["custom_fields"].is_a?(Hash)
      attrs["custom_fields"].delete_if { |key, val| key.to_s =~ /^@/ }
      cfs = []
      attrs["custom_fields"].each do |key, val|
        val.each do |val_val|
          cfs << { "name" => key, "value" => val_val.to_s }
        end
      end
      attrs.merge({'custom_fields' => cfs})
    end

  end
end
