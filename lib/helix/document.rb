require 'helix/media'

module Helix

  class Document < Media

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Image.resource_label_sym #=> :image
    #
    # @return [Symbol] Name of the class.
    def self.resource_label_sym; super; end

  end

end
