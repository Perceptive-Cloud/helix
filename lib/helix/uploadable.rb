module Helix

  # Mixed-in to ORM classes that are capable of being uploaded.

  module Uploadable

    module ClassMethods

      def upload(file_name, opts={})
        url     = upload_server_name(opts)
        payload = { file: File.new(file_name.to_s, "rb") }
        headers = { multipart: true }
        RestClient.post(url, payload, headers)
        http_close
      end

      def upload_server_name(http_open_opts={})
        upload_get(:http_open, ingest_sig_opts, http_open_opts)
      end

      def http_open(opts={})
        upload_server_name(opts)
      end

      def upload_open(opts={})
        upload_server_name(opts)
      end

      def http_close
        upload_get(:http_close)
      end

      def upload_close
        http_close
      end

      private

      def ingest_sig_opts
        cc = config.credentials
        ingest_sig_opts = {
          contributor: cc[:contributor],
          company_id:  cc[:company],
          library_id:  cc[:library],
        }
      end

      def upload_get(action, ingest_sig_opts={}, http_open_opts={})
        guid = config.signature(:ingest, ingest_sig_opts)
        default_http_open_opts = {
          resource_label: "upload_sessions",
          guid:           guid,
          action:         action,
          content_type:   ""
        }
        url_opts = default_http_open_opts.merge(http_open_opts)
        url      = config.build_url(url_opts)
        RestClient.get(url)
      end

    end

    def self.included(klass); klass.extend(ClassMethods); end

  end

end
