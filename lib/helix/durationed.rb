module Helix

  module Durationed

    def generic_download(opts)
      content_type  = opts[:content_type] || ''
      url           = config.build_url( action:         opts[:action],
                                        content_type:   content_type,
                                        guid:           guid,
                                        resource_label: plural_resource_label )
      RestClient.get(url, params: {signature: config.signature(:view)})
    end

    module ClassMethods

      # Used to import tracks from a URL into the Twistage system.
      # API doc reference: /doc/api/track/import
      # API doc reference: /doc/api/video/import
      #
      # @example
      #   track = Helix::Track.import(src:          "www.google.com/track.mp4",
      #                               title:        "Some Title,
      #                               description:  "A random track.")
      #   new_track.track_id # => dd891b83ba39e
      #
      #   video = Helix::Video.import(src:          "www.google.com/video.mp4",
      #                               title:        "Some Title,
      #                               description:  "A random video.")
      #   new_video.video_id # => dd891b83ba39e
      #
      # @param [Hash] attrs The attributes for creating a track.
      # @return [RestClient] The response object.
      def import(attrs={})
        rest_post(:create_many, attrs)
      end

      private

      # Gets the hash used in adding the signature to the API
      # call.
      #
      # @return [Hash] Returns a formatted hash for passing in the signature to the API call.
      def get_params(opts={})
        opts        = { contributor: :helix, library_id: :development }.merge(opts)
        sig         = Helix::Config.instance.signature(:ingest, opts)
        #TODO: Find a better way to handle all the different params needed for a call, such as
        #attributes vs signature params vs process params. :url params is a temp fix.
        url_params  = (opts[:url_params].nil? ? {} : opts[:url_params])
        { params: (params  = { signature: sig }.merge(url_params)) }
      end

      # Gets the url used in the create_many import call.
      #
      # @return [String] Returns the valid url used for the API call.
      def get_url_for(api_call, opts)
        url_opts = url_opts_for(opts[:formats])[api_call].merge(opts)
        Helix::Config.instance.build_url(url_opts)
      end

      # Method allows for :use_raw_xml to be passed into attributes.
      # Normally attributes would be converted to xml, but use_raw_xml
      # takes raw xml as an argument. Allowing for xml files to be
      # used in place of attributes.
      #
      # @param [Hash] attrs The attributes for creating xml.
      # @return [String] Returns xml either from a raw entry or generated from attributes.
      def get_xml(attrs={})
        return attrs[:use_raw_xml] if attrs[:use_raw_xml].present?
        xml_opts = {root: :add}
        { list: { entry: attrs[:url_params] || {} } }.to_xml(xml_opts)
      end

      def rest_post(api_call, attrs)
        RestClient.log    = 'helix.log' if attrs.delete(:log)
        content_type      = url_opts_for[api_call][:content_type]
        content_type_hash = { content_type: "text/#{content_type}" }
        RestClient.post(get_url_for(api_call, attrs),
                        get_xml(attrs),
                        get_params(attrs).merge(content_type_hash))
      end

      # Standard hash values used to generate the create_many
      # url.
      #
      # @return [Hash]
      def url_opts_for(format=nil)
        { slice:       {  action:         :slice,
                          resource_label: plural_resource_label,
                          content_type:   :xml,
                          formats:        format },
          create_many: {  action:         :create_many,
                          resource_label: plural_resource_label,
                          content_type:   :xml }
        }
      end
    end

    def self.included(klass); klass.extend(ClassMethods); end

  end

end
