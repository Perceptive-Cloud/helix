require 'helix/base'

module Helix
  class Image < Base

    def self.guid_name; 'image_id'; end

    # TODO: Messy near-duplication. Clean up.
    def self.plural_media_type; 'images'; end

    def media_type_sym; :image; end

  end
end
