require 'helix/media'

module Helix

  class Track < Media

    include Durationed

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Track.resource_label_sym #=> :track
    #
    # @return [Symbol] Name of the class.
    def self.resource_label_sym; :track; end

    # Used to download data for the given Track.
    #
    # @example
    #   track      = Helix::Track.find("239c59483d346")
    #   track_data = track.download #=> xDC\xF1?\xE9*?\xFF\xD9
    #   File.open("my_track.mp3", "w") { |f| f.puts track_data }
    #
    # @param  [Hash] opts a hash of options for building URL
    # @return [String] Raw track data, save it to a file
    def download(opts={})
      generic_download(opts.merge(action: :file))
    end

    # Used to play the given Track.
    #
    # @example
    #   track      = Helix::Track.find("239c59483d346")
    #   track_data = track.play #=> xDC\xF1?\xE9*?\xFF\xD9
    #
    # @param  [Hash] opts a hash of options for building URL
    # @return [String] Raw track data
    def play(opts={})
      generic_download(opts.merge(action: :play))
    end

  end

end
