require 'helix/base'
require 'active_support/core_ext'

module Helix

  class Video < Base

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
    #
    # @example
    #   video = Helix::Video.import(src:          "www.google.com/video.mp4", 
    #                               title:        "Some Title, 
    #                               description:  "A random video.")
    #   new_video.video_id # => dd891b83ba39e
    #
    # @param [Hash] attrs The attributes for creating a video
    # @return [RestClient] The response object.
    def self.import(attrs={})
      RestClient.post(self.get_url, self.get_xml(attrs), self.get_params)
    end

    private

    def self.get_xml(attrs={})
      return attrs[:use_raw_xml] if attrs[:use_raw_xml].present?
      { list: { entry: attrs } }.to_xml(root: :add)
    end

    def self.get_url_opts
      { action:     :create_many, 
        media_type: plural_media_type,
        format:     :xml }
    end

    def self.get_url
      Helix::Config.instance.build_url(self.get_url_opts)
    end

    def self.get_params
      opts  = { contributor: :helix, library_id: :development }
      sig   = Helix::Config.instance.signature(:ingest, opts)
      { params: { signature: sig } } 
    end

  end
end
