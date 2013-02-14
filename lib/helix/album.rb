require 'helix/media'

module Helix

  class Album < Media

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Album.resource_label_sym #=> :album
    #
    # @return [Symbol] Name of the class.
    def self.resource_label_sym; super; end

    # Currently update is unsupported for album.
    #
    # @param [Hash] opts an array can be passed in so it remains functionally similiar to other update calls.
    # @return [Exception] "Albums Update is not currently supported."
    def update(opts={})
      raise "Albums Update is not currently supported."
    end

    def self.known_attributes
      [:title, :description]
    end 

  end

end
