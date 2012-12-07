module Helix

  module DurationedMedia

    module ClassMethods

      # Standard hash values used to generate the create_many
      # url.
      #
      # @return [Hash]
      def get_url_opts
        { action:     :create_many,
          media_type: plural_media_type,
          format:     :xml }
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
      def get_url
        Helix::Config.instance.build_url(self.get_url_opts)
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
        { list: { entry: attrs } }.to_xml(root: :add)
      end

    end

    def self.included(klass); klass.extend(ClassMethods); end

  end

end
