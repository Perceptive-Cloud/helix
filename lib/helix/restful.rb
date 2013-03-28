module Helix

  module RESTful

    module ClassMethods

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
      def create(attributes={})
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
      def find(guid)
        raise ArgumentError.new("find requires a non-nil guid argument - received a nil argument.") if guid.nil?
        raise Helix::NoConfigurationLoaded.new if config.nil?
        item   = self.new(attributes: { guid_name => guid }, config: config)
        item.load
      end

      def upload(file_name)
        RestClient.post(upload_server_name,
                        { file:       File.new(file_name.to_s, "rb") },
                        { multipart:  true } )
        http_close
      end

      def upload_server_name
        upload_get(:http_open)
      end

      def http_open
        upload_server_name
      end

      def upload_open
        upload_server_name
      end

      def http_close
        upload_get(:http_close)
      end

      def upload_close
        http_close
      end

      def build_url_opts
        {content_type: :xml, resource_label: plural_resource_label}
      end

      private

      def upload_get(action)
        url = config.build_url( resource_label: "upload_sessions",
                                guid:           config.signature(:ingest),
                                action:         action,
                                content_type:   "" )
        RestClient.get(url)
      end

    end

    def self.included(klass); klass.extend(ClassMethods); end

  end

end
