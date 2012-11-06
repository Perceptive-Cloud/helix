require 'helix/base'

module Helix
  class Image < Base

    def self.guid_name; 'image_id'; end

    def media_type_sym; :image; end

  end
end
