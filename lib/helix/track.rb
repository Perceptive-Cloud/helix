require 'helix/media'

module Helix

  class Track < Media

    include DurationedMedia

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Track.resource_label_sym #=> :track
    #
    # @return [Symbol] Name of the class.
    def self.resource_label_sym; super; end

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

    def self.upload_get(action)
      url = config.build_url( resource_label: "upload_sessions",
                              guid:           config.signature(:ingest),
                              action:         action,
                              content_type:   "" )
      RestClient.get(url)
    end

  end

end
