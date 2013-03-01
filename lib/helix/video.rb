require 'helix/media'
require 'active_support/core_ext'

module Helix

  class Video < Media

    include DurationedMedia

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Video.resource_label_sym #=> :video
    #
    # @return [Symbol] Name of the class.
    def self.resource_label_sym; super; end

    # Used to create a slice video from an existing video.
    #
    #
    # @example
    #   xml_string = "<xml></xml>" # Reference Twistage API documentation
    #                              # to see valid xml to pass.
    #   Helix::Video.slice({  guid:         "239c59483d346",
    #                         use_raw_xml:  xml_string  })
    #
    # @param  [Hash] The hash used in this.
    # @return [String] Returns a blank string.
    def self.slice(attrs={})
      rest_post(:slice, attrs)
    end

    # Used to retrieve a stillframe for a video by using
    # the video guid.
    #
    # @example
    #   sf_data = Helix::Video.stillframe_for("239c59483d346") #=> xDC\xF1?\xE9*?\xFF\xD9
    #   File.open("original.jpg", "w") { |f| f.puts sf_data }
    #
    # @param  [String] Guid is the string containing the guid for the video.
    # @param  [Hash] Opts a hash of options for building URL.
    # @return [String] Stillframe jpg data, save it to a file with extension .jpg.
    def self.stillframe_for(guid, opts={})
      RestClient.log  = 'helix.log' if opts.delete(:log)
      url             = stillframe_url(guid, opts)
      RestClient.get(url)
    end

    # Used to download data for the given Video.
    #
    # @example
    #   video      = Helix::Video.find("239c59483d346")
    #   video_data = video.download #=> xDC\xF1?\xE9*?\xFF\xD9
    #   File.open("my_video.mp4", "w") { |f| f.puts video_data }
    #
    # @param  [Hash] opts a hash of options for building URL
    # @return [String] Raw video data, save it to a file
    def download(opts={})
      generic_download(opts.merge(action: :file))
    end

    # Used to play the given Video.
    #
    # @example
    #   video      = Helix::Video.find("239c59483d346")
    #   video_data = video.play #=> xDC\xF1?\xE9*?\xFF\xD9
    #
    # @param  [Hash] opts a hash of options for building URL
    # @return [String] Raw video data
    def play(opts={})
      generic_download(opts.merge(action: :play))
    end

    # Used to retrieve a stillframe data for a video by using
    # the video guid.
    #
    # @example
    #   video   = Helix::Video.find("239c59483d346")
    #   sf_data = video.stillframe #=> xDC\xF1?\xE9*?\xFF\xD9
    #   File.open("original.jpg", "w") { |f| f.puts sf_data }
    #
    # @param  [Hash] opts a hash of options for building URL
    # @return [String] Stillframe jpg data, save it to a file with extension .jpg.
    def stillframe(opts={})
      self.class.stillframe_for(self.guid, opts)
    end

    private

    def self.stillframe_dimensions(opts)
      width   = opts[:width].to_s  + "w" unless opts[:width].nil?
      height  = opts[:height].to_s + "h" unless opts[:height].nil?
      width   = "original" if opts[:width].nil? && opts[:height].nil?
      [width, height]
    end

    def self.stillframe_url(guid, opts)
      server  = opts[:server] || config.credentials[:server] || "service-staging"
      width, height = stillframe_dimensions(opts)
      url     = "#{server}.twistage.com/videos/#{guid}/screenshots/"
      url    << "#{width.to_s}#{height.to_s}.jpg"
    end

    def generic_download(opts)
      content_type  = opts[:content_type] || ''
      url           = config.build_url( action:         opts[:action], 
                                        content_type:   content_type, 
                                        guid:           guid, 
                                        resource_label: plural_resource_label )
      RestClient.get(url, params: {signature: config.signature(:view)})
    end

  end
end
