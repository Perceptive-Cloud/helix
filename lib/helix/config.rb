require 'helix/video'
require 'helix/track'
require 'helix/album'
require 'helix/image'
require 'helix/builds_urls'
require 'helix/has_signatures'
require 'helix/paginates'
require 'singleton'

module Helix

  class Config

    include BuildsUrls
    include HasSignatures
    include Paginates
    include Singleton

    unless defined?(self::DEFAULT_FILENAME)
      DEFAULT_FILENAME = './helix.yml'
    end

    attr_accessor :credentials                              # local
    attr_reader   :response                                 # in Paginates
    attr_reader   :signature_for, :signature_expiration_for # in HasSignatures

    # Creates a singleton of itself, setting the config based on the
    # provided Hash argument.
    #
    # @example
    #   Helix::Config.load_from_hash(
    #     company: 'my-co-nickname',
    #     site:    'http://service-staging.twistage.com'
    #   )
    #   video = Helix::Video.find("8e0701c142ab1") #Uses my_yaml.yml
    #
    # @param [Hash] desired_credentials the k/v pairs used for config
    # @return [Helix::Config] config returns singleton of Helix::Config
    def self.load_from_hash(desired_credentials)
      config = self.instance
      desired_credentials = desired_credentials.symbolize_keys
      config.instance_variable_set(:@credentials, desired_credentials)
      RestClient.proxy = config.proxy
      config
    end

    def self.from_hash(desired_credentials)
      load_from_hash(desired_credentials)
    end

    # Creates a singleton of itself, setting the config
    # to a specified YAML file. If no file is specified the default
    # helix.yml file is used.
    #
    # @example
    #   Helix::Config.load_yaml_file("/some/path/my_yaml.yml")
    #   video = Helix::Video.find("8e0701c142ab1") #Uses my_yaml.yml
    #
    # @param [String] yaml_file_location the yaml file used for config
    # @return [Helix::Config] config returns singleton of Helix::Config
    def self.load_yaml_file(yaml_file_location = DEFAULT_FILENAME)
      creds  = YAML.load(File.open(yaml_file_location))
      config = load_from_hash(creds)
      config.instance_variable_set(:@filename, yaml_file_location)
      config
    end

    def self.load(yaml_file_location = DEFAULT_FILENAME)
      load_yaml_file(yaml_file_location)
    end

    def proxy
      if @credentials[:proxy_uri]
        protocol, uri = @credentials[:proxy_uri].split "://"
        user, pass    = @credentials[:proxy_username], @credentials[:proxy_password]
        proxy_str     = "#{protocol}://"
        proxy_str    += "#{user}:"  if user
        proxy_str    += "#{pass}"   if user && pass
        proxy_str    += '@'         if user
        proxy_str    += "#{uri}"
      elsif @credentials[:proxy_used] == true
        ENV['http_proxy']
      end
    end

  end

end
