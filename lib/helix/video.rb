require 'helix/base'
require 'active_support/core_ext'

module Helix

  class Video < Base

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Video.media_type_sym #=> :video
    #
    # @return [Symbol] Name of the class.
    def self.media_type_sym; :video; end

    # Used to import videos from a URL into the Twistage system.
    #
    # @example
    #   new_video = Helix::Video.import(some_xml)
    #   new_video.video_id # => dd891b83ba39e
    #
    # @params [Hash]
    # @return [Symbol] Name of the class.
    def self.import(opts={})
      config    = Helix::Config.instance
      xml       = { list: { entry: opts } }.to_xml(root: :add)
      url_opts  = { action:       :create_many, 
                    media_type:   plural_media_type,
                    format:       :xml}
      url       = config.build_url(url_opts)
      opts      = { contributor:  :helix, library_id: :development } 
      params    = { signature: config.signature(:ingest, opts)}
      response  = RestClient.post(url, xml, params: params)
      #TODO: Crack may be removeable due to active_support/core_ext
      attrs     = Crack::XML.parse(response)
      self.new(attributes: attrs[media_type_sym.to_s], config: config)
    end
  end

end
