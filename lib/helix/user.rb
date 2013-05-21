require 'helix/media'

module Helix

  class User < Base

    include RESTful

    # @return [String] the license_key associated with newly-created API User
    def self.create(attrs={}); super; end

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::User.resource_label_sym #=> :user
    #
    # @return [Symbol] Name of the class.
    def self.resource_label_sym; :user; end

    # Creates a string associated with a class name pluralized
    #
    # @example
    #   Helix::User.plural_resource_label #=> "users"
    #
    # @return [String] The class name pluralized
    def self.plural_resource_label
      "users"
    end

    def self.known_attributes
      []
    end

  end

end
