require 'helix/base'

module Helix

  module Statistics

    # @example
    #   Helix::Statistics.album_delivery #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.album_delivery(opts={})
      self.image_delivery(opts)
    end

    # @example
    #   Helix::Statistics.album_storage #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.album_storage(opts={})
      self.image_storage(opts)
    end

    # @example
    #   Helix::Statistics.audio_delivery #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.audio_delivery(opts={})
      self.delivery(:track, opts)
    end

    # @example
    #   Helix::Statistics.audio_ingest #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.audio_ingest(opts={})
    end

    # @example
    #   Helix::Statistics.audio_storage #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.audio_storage(opts={})
      memo_cfg = Helix::Config.instance
      url_opts = {media_type: :statistics, action: "track_ingest/disk_usage".to_sym}
      url = memo_cfg.build_url(url_opts)
      memo_cfg.get_response(url, opts.merge(sig_type: :view))
    end

    # @example
    #   Helix::Statistics.image_delivery #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.image_delivery(opts={})
      self.delivery(:image, opts)
    end

    # @example
    #   Helix::Statistics.image_storage #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.image_storage(opts={})
      memo_cfg = Helix::Config.instance
      url_opts = {media_type: :statistics, action: "image_ingest/disk_usage".to_sym}
      url = memo_cfg.build_url(url_opts)
      memo_cfg.get_response(url, opts.merge(sig_type: :view))
    end

    # @example
    #   Helix::Statistics.track_delivery #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.track_delivery(opts={})
      self.audio_delivery(opts)
    end

    # @example
    #   Helix::Statistics.track_ingest #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.track_ingest(opts={})
      self.audio_ingest(opts)
    end

    # @example
    #   Helix::Statistics.track_storage #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.track_storage(opts={})
      self.audio_storage(opts)
    end

    # @example
    #   Helix::Statistics.video_delivery #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.video_delivery(opts={})
      self.delivery(:video, opts)
    end

    # @example
    #   Helix::Statistics.video_ingest #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.video_ingest(opts={})
      # encode, source, or breakdown
    end

    # @example
    #   Helix::Statistics.video_storage #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.video_storage(opts={})
      memo_cfg = Helix::Config.instance
      url_opts = {media_type: :statistics, action: "video_publish/disk_usage".to_sym}
      url = memo_cfg.build_url(url_opts)
      memo_cfg.get_response(url, opts.merge(sig_type: :view))
    end

    private

    def self.delivery(media_type, opts)
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
