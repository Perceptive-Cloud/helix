require 'helix/base'

module Helix

  module Statistics

    # @example
    #   Helix::Statistics.album_delivery_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.album_delivery_stats(opts={})
      self.image_delivery_stats(opts)
    end

    # @example
    #   Helix::Statistics.album_storage_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.album_storage_stats(opts={})
      self.image_storage_stats(opts)
    end

    # @example
    #   Helix::Statistics.audio_delivery_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.audio_delivery_stats(opts={})
      self.delivery_stats(:track, opts)
    end

    # @example
    #   Helix::Statistics.audio_ingest_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.audio_ingest_stats(opts={})
    end

    # @example
    #   Helix::Statistics.audio_storage_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.audio_storage_stats(opts={})
    end

    # @example
    #   Helix::Statistics.image_delivery_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.image_delivery_stats(opts={})
    end

    # @example
    #   Helix::Statistics.image_storage_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.image_storage_stats(opts={})
    end

    # @example
    #   Helix::Statistics.track_delivery_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.track_delivery_stats(opts={})
      self.audio_delivery_stats(opts)
    end

    # @example
    #   Helix::Statistics.track_ingest_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.track_ingest_stats(opts={})
      self.audio_ingest_stats(opts)
    end

    # @example
    #   Helix::Statistics.track_storage_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.track_storage_stats(opts={})
      self.audio_storage_stats(opts)
    end

    # @example
    #   Helix::Statistics.video_delivery_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.video_delivery_stats(opts={})
      self.delivery_stats(:video, opts)
    end

    # @example
    #   Helix::Statistics.video_ingest_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.video_ingest_stats(opts={})
    end

    # @example
    #   Helix::Statistics.video_storage_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.video_storage_stats(opts={})
    end

    private

    def self.delivery_stats(media_type, opts)
      memo_cfg = Helix::Config.instance
      guid     = opts.delete("#{media_type}_id".to_sym)
      url_opts = guid ?
        {guid: guid, media_type: "#{media_type}s".to_sym, action: :statistics} :
        {media_type: :statistics, action: "#{media_type}_delivery".to_sym}
      url = memo_cfg.build_url(url_opts)
      memo_cfg.get_response(url, opts.merge(sig_type: :view))
    end

  end

end
