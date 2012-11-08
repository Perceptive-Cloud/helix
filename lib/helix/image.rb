require 'helix/base'

module Helix

  class Image < Base

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Image.media_type_sym #=> :image
    #
    # @return [Symbol] Name of the class.
    def self.media_type_sym; :image; end

  end

end
