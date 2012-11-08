module Helix

  class Track < Base

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs. 
    #
    #
    # @example
    #   Helix::Track.media_type_sym #=> :track
    #
    # @return [Symbol] Name of the class.
    def self.media_type_sym; :track; end

  end

end
