require 'helix/base'

module Helix

  class Media < Base

    include RESTful, Uploadable

    private

    def generic_download(opts)
      content_type  = opts[:content_type] || ''
      url           = config.build_url( action:         opts[:action],
                                        content_type:   content_type,
                                        guid:           guid,
                                        resource_label: plural_resource_label )
      RestClient.get(url, params: {signature: config.signature(:view)})
    end

  end

end
