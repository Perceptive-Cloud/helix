require 'helix/base'
require 'active_support/core_ext'

module Helix

  class Video < Base

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Video.media_type_sym #=> :video
    #
    # @return [Symbol] Name of the class.
    def self.media_type_sym; :video; end

    # Used to import videos from a URL into the Twistage system.
    # Doc reference: /doc/api/video/import
    #
    # @example
    #   video = Helix::Video.import(src:          "www.google.com/video.mp4",
    #                               title:        "Some Title,
    #                               description:  "A random video.")
    #   new_video.video_id # => dd891b83ba39e
    #
    # @param [Hash] attrs The attributes for creating a video.
    # @return [RestClient] The response object.
    def self.import(attrs={})
      RestClient.post(self.get_url,
                      self.get_xml(attrs),
                      self.get_params(self.extract_params(attrs)))
    end

    private

    # Method allows for :use_raw_xml to be passed into attributes.
    # Normally attributes would be converted to xml, but use_raw_xml
    # takes raw xml as an argument. Allowing for xml files to be
    # used in place of attributes.
    #
    # @param [Hash] attrs The attributes for creating xml.
    # @return [String] Returns xml either from a raw entry or generated from attributes.
    def self.get_xml(attrs={})
      return attrs[:use_raw_xml] if attrs[:use_raw_xml].present?
      { list: { entry: attrs } }.to_xml(root: :add)
    end

    # Standard hash values used to generate the create_many
    # url.
    #
    # @return [Hash]
    def self.get_url_opts
      { action:     :create_many,
        media_type: plural_media_type,
        format:     :xml }
    end

    # Gets the url used in the create_many import call.
    #
    # @return [String] Returns the valid url used for the API call.
    def self.get_url
      Helix::Config.instance.build_url(self.get_url_opts)
    end

    def self.extract_params(attrs)
      [:contributor, :library_id].each_with_object({}) do |param, hash|
        hash[param] = attrs[param] unless attrs[param].nil?
      end
    end

    # Gets the hash used in adding the signature to the API
    # call.
    #
    # @return [Hash] Returns a formatted hash for passing in the signature to the API call.
    def self.get_params(opts={})
      opts  = { contributor: :helix, library_id: :development }.merge(opts)
      sig   = Helix::Config.instance.signature(:ingest, opts)
      { params: { signature: sig } }
    end

  end
end
