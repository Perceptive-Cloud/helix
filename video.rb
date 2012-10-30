require 'active_resource'
require 'yaml'

class Video < ActiveResource::Base

  unless defined?(self::CREDENTIALS)
    FILENAME      = './helix.yml'
    CREDENTIALS   = YAML.load(File.open(FILENAME))
    self.site     = CREDENTIALS['site']
    self.user     = CREDENTIALS['user']
    self.password = CREDENTIALS['password']
  end

  def id; video_id; end

end
