require 'rest-client'
require 'json'
require 'yaml'
require 'nori'
require 'time'
require 'helix/exceptions'

module Helix
  class Base

    unless defined?(self::METHODS_DELEGATED_TO_CLASS)
      METHODS_DELEGATED_TO_CLASS = [ :guid_name, :resource_label_sym, :plural_resource_label ]
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
    def self.find_all(original_opts={})
      raise Helix::NoConfigurationLoaded.new if config.nil?
      opts           = original_opts.clone
      RestClient.log = 'helix.log' if opts.delete(:log)
      data_sets = get_data_sets(opts)
      return [] if data_sets.nil?
      data_sets.map { |attrs| self.new( attributes: massage_attrs(attrs),
                                        config:     config) }
    end

    # (see .find_all)
    def self.where(opts={})
      find_all(opts)
    end

    # (see .find_all)
    # @note this method takes no query options, unlike find_all
    def self.all
      find_all
    end

    # Does a GET call to the api and defaults to content_type xml and
    # signature_type view.
    #
    #
    # @param [Hash] opts a hash of options for parameters passed into the HTTP GET
    # @return [Array] The array of attributes (for a model) in hash form.
    def self.get_data_sets(opts)
      label        = self.plural_resource_label
      url          = config.build_url(content_type:   opts[:content_type] || :xml,
                                      resource_label: label)
      # We allow opts[:sig_type] for internal negative testing only.
      data_sets    = config.get_aggregated_data_sets(url, label, {sig_type: :view}.merge(opts))
    end

    # Creates a string that associates to the class id.
    #
    # @example
    #   Helix::Video.guid_name #=> "video_id"
    #
    # @return [String] The guid name for a specific class.
    def self.guid_name
      "#{resource_label_sym}_id"
    end

    # Creates a string associated with a class name pluralized
    #
    # @example
    #   Helix::Video.plural_resource_label #=> "videos"
    #
    # @return [String] The class name pluralized
    def self.plural_resource_label
      "#{resource_label_sym}s"
    end

    METHODS_DELEGATED_TO_CLASS.each do |meth|
      define_method(meth) { |*args| self.class.send(meth, *args) }
    end

    def initialize(opts)
      @attributes = opts[:attributes]
      @config     = opts[:config]
    end

    # Returns the singleton instance of the Helix::Config.
    def self.config
      Helix::Config.instance
    end

    # (see .config)
    def config
      @config ||= Helix::Config.instance
    end

    # Looks up the custom field value for a given name.
    #
    # @example
    #   video.custom_field('stars_kevin_bacon') #=> "true"
    #
    # @return [String] The value whose key is the given custom field name.
    def custom_field(k)
      custom_fields[k]
    end

    # Returns all custom fields.
    #
    # @example
    #   video.custom_fields #=> { "stars_kevin_bacon" => "true" }
    #
    # @return [Hash] The custom fields in the form { name1 => value1, name2 => value2, ... }
    def custom_fields
      modified_attributes['custom_fields']
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
      memo_cfg      = config
      base_url_opts = {content_type: (opts[:content_type] || :json)}
      url           = memo_cfg.build_url(base_url_opts.merge(guid: self.guid, resource_label: plural_resource_label))
      # We allow opts[:sig_type] for internal negative testing only.
      raw_attrs   = memo_cfg.get_response(url, {sig_type: :view}.merge(opts))
      @attributes = massage_raw_attrs(raw_attrs)
      self
    end
    alias_method :reload, :load

    def to_json
      {resource_label_sym => @attributes}.to_json
    end

    def to_xml
      modified_attributes.to_xml({root: resource_label_sym})
    end

    # Raises an error for missing method calls.
    #
    # @param [Symbol] method_sym The method attempting to be called.
    # @return [String] An error for the method attempting to be called.
    def method_missing(method_sym)
      begin
        @attributes[method_sym.to_s]
      rescue
        raise NoMethodError, "#{method_sym} is not recognized within #{self.class.to_s}'s methods or @attributes"
      end
    end

    private

    def massage_raw_attrs(raw_attrs)
      return raw_attrs['site'] if raw_attrs.respond_to?(:has_key?) && raw_attrs.has_key?('site')
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
        val = [val] unless val.is_a?(Array)
        val.each do |val_val|
          cfs << { "name" => key, "value" => val_val.to_s }
        end
      end
      attrs.merge({'custom_fields' => cfs})
    end

    def modified_attributes
      return if @attributes.nil?
      custom_fields = @attributes['custom_fields']
      return @attributes if custom_fields.nil?
      return @attributes unless custom_fields.respond_to?(:first)
      return @attributes unless custom_fields.first.respond_to?(:[])
      return @attributes if custom_fields.first['name'].nil?
      new_cfs = custom_fields.inject({}) do |memo,cf|
        memo.merge(cf['name'] => cf['value'])
      end
      @attributes.merge('custom_fields' => new_cfs)
    end

  end
end
