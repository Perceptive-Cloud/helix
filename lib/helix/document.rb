require 'helix/media'

module Helix

  class Document < Media

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Document.resource_label_sym #=> :document
    #
    # @return [Symbol] Name of the class.
    def self.resource_label_sym; :document; end

    # Used to download data for the given Document.
    #
    # @example
    #   document      = Helix::Document.find("239c59483d346")
    #   document_data = document.download #=> xDC\xF1?\xE9*?\xFF\xD9
    #   File.open("my_document.mp4", "w") { |f| f.puts document_data }
    #
    # @param  [Hash] opts a hash of options for building URL
    # @return [String] Raw document data, save it to a file
    def download(opts={})
      generic_download(opts.merge(action: :file))
    end

  end

end
