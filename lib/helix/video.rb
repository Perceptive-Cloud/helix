require 'helix/base'
require 'active_support/core_ext'

module Helix

  class Video < Base

    include DurationedMedia

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Video.media_type_sym #=> :video
    #
    # @return [Symbol] Name of the class.
    def self.media_type_sym; :video; end

    # Used to import videos from a URL into the Twistage system.
    # Doc reference: /doc/api/video/import
    #
    # @example
    #   video = Helix::Video.import(src:          "www.google.com/video.mp4",
    #                               title:        "Some Title,
    #                               description:  "A random video.")
    #   new_video.video_id # => dd891b83ba39e
    #
    # @param [Hash] attrs The attributes for creating a video.
    # @return [RestClient] The response object.
    def self.import(attrs={})
      rest_post(:create_many, attrs)
    end

    def self.slice(attrs={})
      rest_post(:slice, attrs)
    end
  end
end
