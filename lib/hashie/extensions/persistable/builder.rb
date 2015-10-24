require 'module_builder/builder'

module Hashie
  module Extensions
    module Persistable
      # Class to build a Persistable module with its own configuration.
      #
      # This allows for invidiual Persistable modules to be included in
      # classes and not impact the global Persistable configuration.
      #
      # @api private
      class Builder < ModuleBuilder::Builder
        def defaults
          { adapter: :json, persist_method: :persist }
        end

        def hooks
          [:add_adapter, :override_persist_method]
        end

        def inclusions
          [Hashie::Extensions::Persistable::Persistence]
        end

        private

        def add_adapter
          @module.__send__(:include, Hashie::Extensions::Persistable.adapters[@adapter])
        end

        def override_persist_method
          return if @persist_method == :persist

          @module.__send__(:alias_method, @persist_method, :persist)
          @module.__send__(:undef_method, :persist)
        end
      end
    end
  end
end
