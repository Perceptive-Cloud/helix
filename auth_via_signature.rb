module ActiveResource
  module Extend
    module AuthViaSignature
      module ClassMethods
        def element_path_with_auth(id, prefix_options = {}, query_options = {})
          query_options.merge!({:signature => self.signature})
          element_path_without_auth(id, prefix_options, query_options)
        end

        def collection_path_with_auth(prefix_options = {}, query_options = {})
          query_options.merge!({:signature => self.signature})
          collection_path_without_auth(prefix_options, query_options)
        end
      end

      def self.included(base)
        base.class_eval do
          extend ClassMethods
          class << self
            alias_method_chain :element_path, :auth
            alias_method_chain :collection_path, :auth
            attr_accessor :signature
          end
        end
      end
    end
  end
end
