require 'helix/base'
require 'active_support/core_ext'

module Helix

  class Video < Base

    include DurationedMedia

    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Video.media_type_sym #=> :video
    #
    # @return [Symbol] Name of the class.
    def self.media_type_sym; :video; end

    def self.slice(attrs={})
      rest_post(:slice, attrs)
    end
  end
end
