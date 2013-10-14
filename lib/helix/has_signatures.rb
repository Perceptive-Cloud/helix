module Helix

  module HasSignatures

    unless defined?(self::VALID_SIG_TYPES)
      REQUIRES_CONTRIBUTOR = Set.new([ :ingest, :upload ])
      SIG_DURATION         = 1200 # in minutes
      TIME_OFFSET          = 1000 * 60 # 1000 minutes, lower to give some margin of error
      VALID_SIG_TYPES      = Set.new([ :ingest, :update, :upload, :view ])
    end

    def clear_signatures!
      @signature_for            = {}
      @signature_expiration_for = {}
    end

    # Fetches the signature for a specific license key.
    #
    # @param [Symbol] sig_type The type of signature required for calls.
    # @param [Hash] opts allows you to overide contributor and license_id
    # @return [String] The signature needed to pass around for calls.
    def signature(sig_type, opts={})
      prepare_signature_memoization
      memo_sig = existing_sig_for(sig_type)
      return memo_sig if memo_sig
      unless VALID_SIG_TYPES.include?(sig_type)
        raise ArgumentError, error_message_for(sig_type)
      end

      lk = license_key
      @signature_expiration_for[lk][sig_type] = Time.now + TIME_OFFSET
      new_sig_url                  = signature_url_for(sig_type, opts)
      @signature_for[lk][sig_type] = RestClient.get(new_sig_url)
    end

    private

    def error_message_for(sig_type)
      "I don't understand '#{sig_type}'. Please give me one of :ingest, :update, or :view."
    end

    def existing_sig_for(sig_type)
      return if sig_expired_for?(sig_type)
      @signature_for[license_key][sig_type]
    end

    def get_contributor_library_company(opts)
      sig_param_labels = [:contributor, :library, :company]
      scoping_proc     = lambda { |key| opts[key] || credentials[key] }
      contributor, library, company = sig_param_labels.map(&scoping_proc)
      contributor    ||= 'helix_default_contributor'
      [contributor, library, company]
    end

    # Returns the proper Twistage ApiController action for the specific sig_type.
    #
    # @param [Symbol] sig_type The type of signature required for calls.
    # @return [String] The action, such as ingest_key in '.../api/ingest_key'
    # which will return a usable signature of that type when given a proper
    # licenseKey parameter in the query string.
    #
    # Why does this method exist? The key types returnable by the Twistage API
    # include [ :ingest, :update, :view ]. Typically, :update and :view keys are
    # memoized, whereas :ingest keys are not.
    #
    # However, Helix upload actions require persistent signatures across multiple
    # sub-actions, so within Helix, we have provided the alias :upload, which
    # means "memoized :ingest". Interactions with the Twistage API will still be
    # as :ingest, but the internal label within Helix will be :upload, in order
    # to easily allow the needed memoization and also disambiguate.
    def key_action_for(sig_type)
      key_type = {upload: :ingest}[sig_type] || sig_type
      "#{key_type}_key"
    end

    def license_key
      @credentials[:license_key]
    end

    def prepare_signature_memoization
      lk = license_key
      @signature_for                ||= {}
      @signature_expiration_for     ||= {}
      @signature_for[lk]            ||= {}
      @signature_expiration_for[lk] ||= {}
    end

    def sig_expired_for?(sig_type)
      # We intentionally only allow one use each for ingest signatures
      return true if sig_type == :ingest
      expires_at = @signature_expiration_for[license_key][sig_type]
      return true if expires_at.nil?
      expires_at <= Time.now
    end

    def signature_url_for(sig_type, opts={})
      contributor, library, company = get_contributor_library_company(opts)
      key_action = key_action_for(sig_type)
      url  = "#{credentials[:site]}/api/#{key_action}?"
      url += "licenseKey=#{credentials[:license_key]}&duration=#{SIG_DURATION}"
      url += "&contributor=#{contributor}" if REQUIRES_CONTRIBUTOR.include?(sig_type)
      url += "&library_id=#{library}"   if library
      url += "&company_id=#{company}"   if company
      url
    end

  end

end
