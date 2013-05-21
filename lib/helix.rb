require 'helix/restful'
require 'helix/uploadable'
require 'helix/durationed_media'
require 'helix/video'
require 'helix/track'
require 'helix/tag'
require 'helix/album'
require 'helix/image'
require 'helix/document'
require 'helix/config'
require 'helix/statistics'
require 'helix/library'
require 'helix/user'
require 'active_support/core_ext'

module Helix

  def self.scope_to_library(lib_id)
    Helix::Config.instance.credentials[:library_id] = lib_id
  end

end
