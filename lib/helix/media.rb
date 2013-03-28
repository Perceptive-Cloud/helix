require 'helix/base'

module Helix

  ## TODO: Media is a bad name, as it is also ancestral to Library, which really isn't a media type
  ## Create a new Mixin called Restful, pull current Media logic into that
  ## Mix Restful into Media
  ## Remove Media ancestry from Library
  ## Mix Restful into Library
  class Media < Base

    include RESTful

  end

end
