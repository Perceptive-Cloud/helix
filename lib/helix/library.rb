require 'helix/media'

module Helix

  class Library < Media

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Image.media_type_sym #=> :image
    #
    # @return [Symbol] Name of the class.
    def self.media_type_sym; :library; end

    # Creates a string associated with a class name pluralized
    #
    # @example
    #   Helix::Video.plural_media_type #=> "videos"
    #
    # @return [String] The class name pluralized
    def self.plural_media_type
      "#{self.media_type_sym.to_s.gsub(/y/, '')}ies"
    end

  end

end