module Helix

  module Paginates

    unless defined?(self::STARTING_PAGE)
      ITEMS_PER_PAGE = 100
      STARTING_PAGE  = 1
    end

    # Makes aggregated calls to get_response with pagination
    # folding/injecting/accumulating the results into a single output set.
    #
    # @param [String] url the base part of the URL to be used
    # @param [String] plural_resource_label: "videos", "tracks", etc.
    # @param [Hash] original_opts a hash of options for building URL additions
    # @return [Array] The accumulated attribute Hashes for ORM instances
    def get_aggregated_data_sets(url, plural_resource_label, original_opts={})
      data_sets, page, per_page = [], STARTING_PAGE
      specific_page_requested   = specific_page_requested?(original_opts)
      begin
        aggregation_opts = {page: page, per_page: ITEMS_PER_PAGE}.merge(original_opts)
        raw_response = get_response(url, {sig_type: :view}.merge(aggregation_opts))
        data_set     = raw_response[plural_resource_label]
        data_sets   += data_set if data_set
        page        += 1
      end until specific_page_requested || last_page?
      data_sets
    end

    # Creates additional URL stubbing that can be used in conjuction
    # with the base_url to create RESTful URLs
    #
    # @param [String] url the base part of the URL to be used
    # @param [Hash] original_opts a hash of options for building URL additions
    # @return [String] The full RESTful URL string object
    def get_response(url, original_opts={})
      opts     = massage_custom_fields_in(original_opts)
      sig_type = opts.delete(:sig_type)
      params   = opts.merge(signature: signature(sig_type, opts))
      begin
        @response = RestClient.get(url, params: params)
      rescue RestClient::InternalServerError => e
        raise NetworkError, "Unable to access url #{url} with params #{params}"
      end
      parse_response_by_url_format(@response, url)
    end

    private

    # Reports whether the most recent response's headers have a true :is_last_page value
    #
    # @return [Boolean] As above. Returns false if no such header is found,
    # or if there is an explictly false value.
    def last_page?
      return false unless @response
      return false unless @response.headers
      return true  unless @response.headers.has_key?(:is_last_page)
      @response.headers[:is_last_page] == "true"
    end

    def massage_custom_fields_in(opts)
      return opts.clone unless opts.has_key?(:custom_fields)
      cf_opts = opts.delete(:custom_fields)
      cf_opts.inject(opts.clone) do |memo,pair|
        k,v = pair
        memo.merge("custom_fields[#{k}]" => v)
      end
    end

    def specific_page_requested?(original_opts)
      original_opts.has_key?(:page)
    end

    def parse_response_by_url_format(response, url)
      return JSON.parse(response)              if url =~ /json/
      return response                          if url =~ /csv/
      return parse_xml_response(response, url) if url =~ /xml/
      raise "Could not parse #{url}"
    end

    def parse_xml_response(response, url)
      #TODO: Cleanup Nori and response gsub.
      parser = Nori.new(parser: :nokogiri)
      xml = response.gsub(/<custom-fields type='array'>/, "<custom-fields type='hash'>")
      parser.parse(xml)
    end

  end

end
