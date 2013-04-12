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
    def self.resource_label_sym; :track; end

  end

end
