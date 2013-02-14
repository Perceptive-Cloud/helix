require 'helix/media'

module Helix

  class Library < Media

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Library.resource_label_sym #=> :library
    #
    # @return [Symbol] Name of the class.
    def self.resource_label_sym; super; end

    # Creates a string associated with a class name pluralized
    #
    # @example
    #   Helix::Library.plural_resource_label #=> "libraries"
    #
    # @return [String] The class name pluralized
    def self.plural_resource_label
      "libraries"
    end

    def self.known_attributes
      [:player_profile, :ingest_profile, :secure_stream_callback_url, :hooks_attributes]
    end

  end

end
