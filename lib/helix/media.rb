require 'helix/base'

module Helix

  class Media < Base

    include RESTful, Uploadable, Downloadable

  end

end
