require 'active_resource'
require 'yaml'
require './auth_via_signature.rb'

class Video < ActiveResource::Base
  include ActiveResource::Extend::AuthViaSignature

  unless defined?(self::CREDENTIALS)
    FILENAME      = './helix.yml'
    CREDENTIALS   = YAML.load(File.open(FILENAME))
    self.site     = CREDENTIALS['site']
    # TODO: switchable between U+P vs. Sig authentication
    #self.user     = CREDENTIALS['user']
    #self.password = CREDENTIALS['password']
  end

  def id; video_id; end

  def self.signature
    # TODO: Memoize (if it's valid)
    url = "#{CREDENTIALS['site']}/api/update_key?licenseKey=#{CREDENTIALS['license_key']}&duration=1200"
    @signature = Net::HTTP.get_response(URI.parse(url)).body
  end

end
