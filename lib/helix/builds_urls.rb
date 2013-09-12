module Helix

  module BuildsUrls

    unless defined?(self::SCOPES)
      SCOPES = [:reseller, :company, :library]
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] base_url the base part of the URL to be used
    # @param [Hash] opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def add_sub_urls(base_url, opts)
      guid, action, format = [:guid, :action, :formats].map { |sub| opts[sub] }
      url   = sub_url_scoping(base_url, opts)
      url  += "/#{guid}"            if guid
      url  += "/formats/#{format}"  if format
      url  += "/#{action}"          if action
      return url if opts[:content_type].blank?
      "#{url}.#{opts[:content_type]}"
    end

    # Creates a full RESTful URL to be used for HTTP requests.
    #
    # @param [Hash] opts a hash of options for building URL
    # @return [String] The full RESTful URL string object
    def build_url(opts={})
      opts[:content_type]   ||= :xml
      opts[:resource_label] ||= :videos
      base_url                = get_base_url(opts)
      url                     = add_sub_urls(base_url, opts)
    end

    # Creates the base url with information collected from credentials.
    #
    # @param [Hash] opts a hash of options for building URL
    # @return [String] The base RESTful URL string object
    def get_base_url(opts)
      creds     = credentials
      base_url  = creds[:site]
      return base_url if opts[:guid] || opts[:action] == :create_many
      reseller, company, library = SCOPES.map { |scope| creds[scope] }
      base_url += "/resellers/#{reseller}" if reseller
      if company
        base_url += "/companies/#{company}"
        base_url += "/libraries/#{library}" if library
      end
      base_url
    end

    private

    def sub_url_scoping(base_url, opts)
      resource_label = opts[:resource_label]
      if resource_label == 'libraries' and base_url !~ /companies/
        co_id = opts[:company] || credentials[:company]
        raise "No company to scope to: #{credentials}" if co_id.nil?
        resource_label = "companies/#{co_id}/libraries"
      end
      "#{base_url}/#{resource_label}"
    end

  end

end
