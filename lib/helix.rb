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

  # @param [String] The name of the Company to scope to.
  def self.scope_to_company(co_id)
    Helix::Config.instance.credentials.delete(:library)
    Helix::Config.instance.credentials[:company] = co_id
  end

  # @param [String] The name of the Library to scope to.
  def self.scope_to_library(lib_id)
    Helix::Config.instance.credentials[:library] = lib_id
  end

  # @param [String] The license key to use.
  def self.set_license_key(license_key)
    Helix::Config.instance.credentials[:license_key] = license_key
  end

end
