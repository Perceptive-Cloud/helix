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

    # This is being used to override the current way of calling to our system
    # since the current way uses pagination. This method does not add in
    # pagination. Adding paginaton to Tags currently breaks the call. This
    # method should be a temporary fix.
    #
    # Does a GET call to the api and defaults to content_type xml and
    # signature_type view.
    #
    #
    # @param [Hash] opts a hash of options for parameters passed into the HTTP GET
    # @return [Array] The array of attributes (for a model) in hash form.
    def self.get_data_sets(opts)
      url          = config.build_url(content_type:   opts[:content_type] || :xml,
                                      resource_label: self.plural_resource_label)
      # We allow opts[:sig_type] for internal negative testing only.
      raw_response = config.get_response(url, {sig_type: :view}.merge(opts))
      data_sets    = raw_response[plural_resource_label]
    end
  end
end
