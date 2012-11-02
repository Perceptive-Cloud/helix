require 'helix/base'

module Helix
  class Video < Base

    def self.guid_name; 'video_id'; end

    # TODO: Messy near-duplication. Clean up.
    def self.plural_media_type; 'videos'; end

    def media_type_sym; :video; end

  end
end
