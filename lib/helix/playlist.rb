require 'helix/media'

module Helix

  class Playlist < Base

    include RESTful

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Playlist.resource_label_sym #=> :playlist
    #
    # @return [Symbol] Name of the class.
    def self.resource_label_sym; :playlist; end
      
            
    # @return an override id string specfic to Playlist for Base.guid_name  
    def self.guid_name; 'id'; end

  end

end
