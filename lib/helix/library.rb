require 'helix/media'

module Helix

  class Library < Base

    include RESTful

    # @return [String] A blank String
    def self.create(attrs={}); super; end

    def self.find(nickname, opts={})
      default_opts = process_opts(opts) 
      super(nickname, opts.merge(default_opts))
    end

    # Creates a string that associates to the class id.
    #
    # @example
    #   Helix::Library.guid_name #=> "name"
    #
    # @return [String] The guid name for a specific class.
    def self.guid_name
      "name"
    end
    
    def process_opts(opts)
      {content_type: :xml}.merge(opts)
    end

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Library.resource_label_sym #=> :library
    #
    # @return [Symbol] Name of the class.
    def self.resource_label_sym; :library; end

    # Creates a string associated with a class name pluralized
    #
    # @example
    #   Helix::Library.plural_resource_label #=> "libraries"
    #
    # @return [String] The class name pluralized
    def self.plural_resource_label
      "libraries"
    end

  end

end
