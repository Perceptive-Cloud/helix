require 'helix/media'

module Helix

  class Library < Media

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Library.media_type_sym #=> :library
    #
    # @return [Symbol] Name of the class.
    def self.media_type_sym; :library; end

    # Creates a string associated with a class name pluralized
    #
    # @example
    #   Helix::Library.plural_media_type #=> "libraries"
    #
    # @return [String] The class name pluralized
    def self.plural_media_type
      "#{self.media_type_sym.to_s.gsub(/y/, '')}ies"
    end

    def self.known_attributes
      [:player_profile, :ingest_profile, :secure_stream_callback_url, :hooks_attributes]
    end

  end

end