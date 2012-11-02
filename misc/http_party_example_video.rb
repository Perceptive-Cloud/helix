require 'httparty'
require 'yaml'
require './auth_via_signature.rb'

class Video
  include HTTParty
  unless defined?(self::CREDENTIALS)
    FILENAME      = './helix.yml'
    CREDENTIALS   = YAML.load(File.open(FILENAME))
    base_uri CREDENTIALS['site']
    # TODO: switchable between U+P vs. Sig authentication
    #self.user     = CREDENTIALS['user']
    #self.password = CREDENTIALS['password']
  end

  def id; video_id; end

  def signature
    # TODO: Memoize (if it's valid)
    url = "#{CREDENTIALS['site']}/api/update_key?licenseKey=#{CREDENTIALS['license_key']}&duration=1200"
    Net::HTTP.get_response(URI.parse(url)).body
  end

  def initialize
    self.class.default_params :signature => self.signature 
  end

  def update(options = {})
    self.class.put('/videos/b0e79e80183ab', {:body => {:video => {title: "New HTTP title"}}})
  end

end