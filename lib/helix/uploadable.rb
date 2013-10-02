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

      # OPTIMIZE: This only accepts a flat Hash for http_open_opts, and
      # doesn't encode. Neither is a big problem for the expected use
      # cases, but should still be noted.
      def add_params_to_url(url, http_open_opts)
        return url if http_open_opts == {}
        query_string = http_open_opts.inject([]) do |memo,pair|
          k,v   = *pair
          memo << "#{k}=#{v}"
        end.join('&')
        "#{url}?#{query_string}"
      end

      def ingest_sig_opts
        cc = config.credentials
        ingest_sig_opts = {
          contributor: cc[:contributor],
          company_id:  cc[:company],
          library_id:  cc[:library],
        }
      end

      def upload_get(action, ingest_sig_opts={}, http_open_opts={})
        guid     = config.signature(:ingest, ingest_sig_opts)
        url_opts = {
          resource_label: "upload_sessions",
          guid:           guid,
          action:         action,
          content_type:   ""
        }
        url      = config.build_url(url_opts)
        url      = add_params_to_url(url, http_open_opts)
        RestClient.get(url)
      end

    end

    def self.included(klass); klass.extend(ClassMethods); end

  end

end
