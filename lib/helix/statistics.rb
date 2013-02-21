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
      image_delivery(opts)
    end

    # @example
    #   Helix::Statistics.album_storage #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.album_storage(opts={})
      image_storage(opts)
    end

    # @example
    #   Helix::Statistics.audio_delivery #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.audio_delivery(opts={})
      delivery(:track, opts)
    end

    # @example
    #   Helix::Statistics.audio_ingest #=> Array of Hashes of stats data
    #
    # Takes one of :encode, :source, or :breakdown as the :action value. Defaults to :breakdown.
    #
    # @return [Array of Hashes] Statistics information.
    def self.audio_ingest(opts={})
      ingest(:track, opts)
    end

    # @example
    #   Helix::Statistics.audio_storage #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.audio_storage(opts={})
      storage(:track, opts)
    end

    # @example
    #   Helix::Statistics.image_delivery #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.image_delivery(opts={})
      delivery(:image, opts)
    end

    # @example
    #   Helix::Statistics.image_storage #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.image_storage(opts={})
      storage(:image, opts)
    end

    # @example
    #   Helix::Statistics.track_delivery #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.track_delivery(opts={})
      audio_delivery(opts)
    end

    # @example
    #   Helix::Statistics.track_ingest #=> Array of Hashes of stats data
    #
    # Takes one of :encode, :source, or :breakdown as the :action value. Defaults to :breakdown.
    #
    # @return [Array of Hashes] Statistics information.
    def self.track_ingest(opts={})
      audio_ingest(opts)
    end

    # @example
    #   Helix::Statistics.track_storage #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.track_storage(opts={})
      audio_storage(opts)
    end

    # @example
    #   Helix::Statistics.video_delivery #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.video_delivery(opts={})
      delivery(:video, opts)
    end

    # @example
    #   Helix::Statistics.video_ingest #=> Array of Hashes of stats data
    #
    # Takes one of :encode, :source, or :breakdown as the :action value. Defaults to :breakdown.
    #
    # @return [Array of Hashes] Statistics information.
    def self.video_ingest(opts={})
      ingest(:video, opts)
    end

    # @example
    #   Helix::Statistics.video_storage #=> Array of Hashes of stats data
    #
    # @return [Array of Hashes] Statistics information.
    def self.video_storage(opts={})
      storage(:video, opts)
    end

    private

    def self.delivery(resource_label, original_opts)
      opts          = original_opts.clone
      memo_cfg      = Helix::Config.instance
      content_type  = opts.delete(:content_type)
      guid          = opts.delete("#{resource_label}_id".to_sym)
      url_opts      = guid ?
        {guid: guid, resource_label: "#{resource_label}s".to_sym, action: :statistics} :
        {resource_label: :statistics, action: "#{resource_label}_delivery".to_sym}
      url_opts.merge!(content_type: content_type) if content_type
      url = memo_cfg.build_url(url_opts)
      # We allow opts[:sig_type] for internal negative testing only.
      memo_cfg.get_response(url, {sig_type: :view}.merge(opts))
    end

    def self.ingest(resource_label, original_opts)
      opts            = original_opts.clone
      opts[:action] ||= :breakdown
      action_prefix   = ingest_action_prefix_for(resource_label)
      storage(resource_label, opts.merge(action: :"#{action_prefix}/#{opts[:action]}"))
    end

    def self.storage(resource_label, original_opts)
      opts          = original_opts.clone
      memo_cfg      = Helix::Config.instance
      content_type  = opts.delete(:content_type)
      action        = opts.delete(:action) || storage_action_for(resource_label)
      url_opts      = {resource_label: :statistics, action: action}
      url_opts.merge!(content_type: content_type) if content_type
      url = memo_cfg.build_url(url_opts)
      # We allow opts[:sig_type] for internal negative testing only.
      memo_cfg.get_response(url, {sig_type: :view}.merge(opts))
    end

    def self.ingest_action_prefix_for(resource_label)
      STORAGE_ACTION_FOR[resource_label].split('/').first
    end

    def self.storage_action_for(resource_label)
      STORAGE_ACTION_FOR[resource_label].to_sym
    end

  end

end
