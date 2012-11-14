require 'helix/base'

module Helix

  module Statistics

    # @example
    #   Helix::Statistics.audio_delivery_stats #=> Hash of stats data
    #
    # @return [Hash] Statistics information.
    def self.audio_delivery_stats(opts={})
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

  end

end
