module Helix

  class Track < Base

    include DurationedMedia

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Track.media_type_sym #=> :track
    #
    # @return [Symbol] Name of the class.
    def self.media_type_sym; :track; end

    # Used to import tracks from a URL into the Twistage system.
    # Doc reference: /doc/api/track/import
    #
    # @example
    #   track = Helix::Track.import(src:          "www.google.com/track.mp4",
    #                               title:        "Some Title,
    #                               description:  "A random track.")
    #   new_track.track_id # => dd891b83ba39e
    #
    # @param [Hash] attrs The attributes for creating a track.
    # @return [RestClient] The response object.
    def self.import(attrs={})
      rest_post(:create_many, attrs)
    end

  end

end
