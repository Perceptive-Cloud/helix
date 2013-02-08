require 'helix/base'

module Helix
  class Media < Base
    # Creates a new record via API and then returns an instance of that record.
    #
    # Example is using Video class since Video inherits from Base. This won't
    # normally be called as Helix::Base.create
    #
    # @example
    #   Helix::Album.create({title: "My new album"})
    #
    # @param [Hash] attributes a hash containing the attributes used in the create
    # @return [Base] An instance of Helix::Base
    def self.create(attributes={})
      url       = config.build_url(media_type:    plural_media_type,
                                   content_type:  :xml)
      response  = RestClient.post(url, attributes.merge(signature: config.signature(:update)))
      attrs     = Hash.from_xml(response)
      self.new(attributes: attrs[media_type_sym.to_s], config: config)
    end

    # Finds and returns a record in instance form for a class, through
    # guid lookup.
    #
    # @example
    #   video_guid  = "8e0701c142ab1"
    #   video       = Helix::Video.find(video_guid)
    #
    # @param [String] guid an id in guid form.
    # @return [Base] An instance of Helix::Base
    def self.find(guid)
      item   = self.new(attributes: { guid_name => guid }, config: config)
      item.load
    end

    # Deletes the record of the Helix::Base instance.
    #
    # @example
    #   video = Helix::Video.create({title: "Some Title"})
    #   video.destroy
    #
    # @return [String] The response from the HTTP DELETE call.
    def destroy
      url      = config.build_url(content_type: :xml, guid: guid, media_type: plural_media_type)
      RestClient.delete(url, params: {signature: config.signature(:update)})
    end

    # Updates instance and record with attributes passed in.
    #
    # @example
    #   video = Helix::Video.find(video_guid)
    #   video.update({title: "My new title"})
    #
    # @param [Hash] opts a hash of attributes to update the instance with.
    # @return [Base] Returns an instance of the class after update.
    def update(opts={})
      RestClient.log = 'helix.log' if opts.delete(:log)
      memo_cfg = config
      url      = memo_cfg.build_url(content_type: :xml,
                                    guid:         guid,
                                    media_type:   plural_media_type)
      params   = {signature: memo_cfg.signature(:update)}.merge(media_type_sym => opts)
      RestClient.put(url, params)
      self
    end
  end
end