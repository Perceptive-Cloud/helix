require 'helix/base'

module Helix

  ## TODO: Media is a bad name, as it is also ancestral to Library, which really isn't a media type
  ## Create a new Mixin called Restful, pull current Media logic into that
  ## Mix Restful into Media
  ## Remove Media ancestry from Library
  ## Mix Restful into Library
  class Media < Base

    include RESTful

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

    private

    def build_url_opts
      self.class.build_url_opts.merge({guid: guid, resource_label: plural_resource_label})
    end

  end

end
