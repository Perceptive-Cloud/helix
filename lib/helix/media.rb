require 'helix/base'

module Helix

  ## TODO: Media is a bad name, as it is also ancestral to Library, which really isn't a media type
  ## Create a new Mixin called Restful, pull current Media logic into that
  ## Mix Restful into Media
  ## Remove Media ancestry from Library
  ## Mix Restful into Library
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
      raise Helix::NoConfigurationLoaded.new if config.nil?
      url       = config.build_url(build_url_opts)
      response  = RestClient.post(url, attributes.merge(signature: config.signature(:update)))
      attrs     = Hash.from_xml(response)
      self.new(attributes: attrs[resource_label_sym.to_s], config: config)
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
      raise ArgumentError.new("find requires a non-nil guid argument - received a nil argument.") if guid.nil?
      raise Helix::NoConfigurationLoaded.new if config.nil?
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
      url = config.build_url(build_url_opts)
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
    def update(original_opts={})
      opts           = original_opts.clone
      RestClient.log = 'helix.log' if opts.delete(:log)
      memo_cfg = config
      url      = memo_cfg.build_url(build_url_opts)
      params   = {signature: memo_cfg.signature(:update)}.merge(resource_label_sym => opts)
      RestClient.put(url, params)
      self
    end

    def self.upload(file_name)
      RestClient.post(upload_server_name,
                      { file:       File.new(file_name.to_s, "rb") },
                      { multipart:  true } )
      http_close
    end

    def self.upload_server_name
      upload_get(:http_open)
    end

    def self.http_open
      upload_server_name
    end

    def self.upload_open
      upload_server_name
    end

    def self.http_close
      upload_get(:http_close)
    end

    def self.upload_close
      http_close
    end

    private

    def self.build_url_opts
      {content_type: :xml, resource_label: plural_resource_label}
    end

    def self.upload_get(action)
      url = config.build_url( resource_label: "upload_sessions",
                              guid:           config.signature(:ingest),
                              action:         action,
                              content_type:   "" )
      RestClient.get(url)
    end

    def build_url_opts
      self.class.build_url_opts.merge({guid: guid, resource_label: plural_resource_label})
    end

  end

end
