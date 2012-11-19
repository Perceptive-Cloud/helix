require 'helix/base'

module Helix

  module Statistics

    unless defined?(self::STORAGE_ACTION_FOR)
      STORAGE_ACTION_FOR = {
        track: "track_ingest/disk_usage",
        image: "image_ingest/disk_usage",
        video: "video_publish/disk_usage",
      }
    end

    # @example
    #   Helix::Statistics.album_delivery #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.album_delivery(opts={})
      self.image_delivery(opts)
    end

    # @example
    #   Helix::Statistics.album_storage #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.album_storage(opts={})
      self.image_storage(opts)
    end

    # @example
    #   Helix::Statistics.audio_delivery #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.audio_delivery(opts={})
      self.delivery(:track, opts)
    end

    # @example
    #   Helix::Statistics.audio_ingest #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.audio_ingest(opts={})
    end

    # @example
    #   Helix::Statistics.audio_storage #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.audio_storage(opts={})
      self.storage(:track, opts)
    end

    # @example
    #   Helix::Statistics.image_delivery #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.image_delivery(opts={})
      self.delivery(:image, opts)
    end

    # @example
    #   Helix::Statistics.image_storage #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.image_storage(opts={})
      self.storage(:image, opts)
    end

    # @example
    #   Helix::Statistics.track_delivery #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.track_delivery(opts={})
      self.audio_delivery(opts)
    end

    # @example
    #   Helix::Statistics.track_ingest #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.track_ingest(opts={})
      self.audio_ingest(opts)
    end

    # @example
    #   Helix::Statistics.track_storage #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.track_storage(opts={})
      self.audio_storage(opts)
    end

    # @example
    #   Helix::Statistics.video_delivery #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.video_delivery(opts={})
      self.delivery(:video, opts)
    end

    # @example
    #   Helix::Statistics.video_ingest #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.video_ingest(opts={})
      # encode, source, or breakdown
    end

    # @example
    #   Helix::Statistics.video_storage #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.video_storage(opts={})
      self.storage(:video, opts)
    end

    private

    def self.delivery(media_type, opts)
      memo_cfg = Helix::Config.instance
      guid     = opts.delete("#{media_type}_id".to_sym)
      url_opts = guid ?
        {guid: guid, media_type: "#{media_type}s".to_sym, action: :statistics} :
        {media_type: :statistics, action: "#{media_type}_delivery".to_sym}
      url = memo_cfg.build_url(url_opts)
      # We allow opts[:sig_type] for internal negative testing only.
      memo_cfg.get_response(url, {sig_type: :view}.merge(opts))
    end

    def self.storage(media_type, opts)
      memo_cfg = Helix::Config.instance
      url_opts = {media_type: :statistics, action: storage_action_for(media_type)}
      url = memo_cfg.build_url(url_opts)
      # We allow opts[:sig_type] for internal negative testing only.
      memo_cfg.get_response(url, {sig_type: :view}.merge(opts))
    end

    def self.storage_action_for(media_type)
      STORAGE_ACTION_FOR[media_type].to_sym
    end

  end

end
