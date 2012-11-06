require 'helix/base'

module Helix
  class Album < Base

    def self.media_type_sym; :album; end

    def update(opts={})
      raise "Albums Update is not currently supported."
    end

  end
end
