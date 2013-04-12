require 'rest-client'
require 'json'
require 'yaml'
require 'nori'

module Helix
  class Tag < Base
    # The class name, to be used by supporting classes. Such as Config which uses
    # this method as a way to build URLs.
    #
    #
    # @example
    #   Helix::Tag.resource_label_sym #=> :tag
    #
    # @return [Symbol] Name of the class.
    def self.resource_label_sym; :tag; end
  end
end
