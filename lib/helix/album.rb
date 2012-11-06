require 'helix/base'

module Helix
  class Album < Base

    def self.guid_name; 'album_id'; end

    # TODO: Messy near-duplication. Clean up.
    def self.plural_media_type; 'albums'; end

    def media_type_sym; :album; end

    def update(opts={})
      raise "Albums Update is not currently supported."
    end

  end
end
