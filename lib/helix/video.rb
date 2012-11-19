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
    # @return [Helix::Video] An instance of Helix::Video.
    def self.import(attrs={})
      config    = Helix::Config.instance
      xml       = { list: { entry: attrs } }.to_xml(root: :add)
      url_opts  = { action:       :create_many, 
                    media_type:   plural_media_type,
                    format:       :xml}
      url       = config.build_url(url_opts)
      opts      = { contributor:  :helix, library_id: :development } 
      params    = { signature: config.signature(:ingest, opts)}
      response  = RestClient.post(url, xml, params: params)
      attrs     = Hash.from_xml(response)
      self.new(attributes: attrs[media_type_sym.to_s], config: config)
    end
  end

end
