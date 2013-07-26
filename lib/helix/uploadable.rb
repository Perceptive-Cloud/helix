module Helix

  # Mixed-in to ORM classes that are capable of being uploaded.

  module Uploadable

    module ClassMethods

      def upload(file_name)
        url     = upload_server_name
        payload = { file: File.new(file_name.to_s, "rb") }
        headers = { multipart:  true }
        RestClient.post(url, payload, headers)
        http_close
      end

      def upload_server_name
        upload_get(:http_open, ingest_opts)
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

      private

      def ingest_opts
        cc = config.credentials
        ingest_opts = {
          contributor: cc[:contributor],
          company_id:  cc[:company],
          library_id:  cc[:library],
        }
      end

      def upload_get(action, opts={})
        guid = config.signature(:ingest, opts)
        url  = config.build_url(resource_label: "upload_sessions",
                                guid:           guid,
                                action:         action,
                                content_type:   "" )
        RestClient.get(url)
      end

    end

    def self.included(klass); klass.extend(ClassMethods); end

  end

end
