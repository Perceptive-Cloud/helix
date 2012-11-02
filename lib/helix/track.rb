module Helix
  class Track < Base

    def self.guid_name; 'track_id'; end

    # TODO: Messy near-duplication. Clean up.
    def self.plural_media_type; 'tracks'; end

    def media_type_sym; :track; end

  end
end
