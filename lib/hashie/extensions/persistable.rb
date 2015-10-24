require 'hashie/extensions/persistable/builder'
require 'module_builder/buildable'

module Hashie
  module Extensions
    # Give persistance capabilities to a Hash via different file adapters.
    #
    # @api public
    module Persistable
      include ModuleBuilder::Buildable

      # Raised when there is an error with the configuration for a Persistable
      # Hash. This is a generic error and shouldn't be raised directly, but
      # should be subclassed appropriately.
      PersistableError = Class.new(StandardError)

      # Raised when there is no adapter set for the type of data to write.
      UnknownAdapter = Class.new(PersistableError)

      # Raised when there is no location set for where to persist the Hash.
      UnknownLocation = Class.new(PersistableError)

      # An internal adapter identifier-to-adapter map used for setup.
      #
      # @return [Hash<Symbol=>Module>]
      #
      # @api private
      def self.adapters
        @adapters ||= {}
      end

      # Load a source into a new copy of the Hash class.
      #
      # @param [#read, #to_io, #to_str] source The source to load from.
      # @param [Hash] options
      # @option [#load] adapter An adapter that responds to #load.
      #
      # @return [Hash]
      #
      # @api public
      def self.load(source, options = {})
        adapter = options.fetch(:adapter) { fail(UnknownAdapter, 'You did not specify an adapter for this Persistable Hash.'.freeze) }

        adapter.load(source)
      end

      # Persist a Hash to a file in a specified format.
      #
      # @param [Hash] hash The hash to persist.
      # @param [Hash] options
      # @option options [#write] adapter An adapter that responds to #write.
      # @option options [#write] target The target to persist to.
      #
      # @return [#read]
      #
      # @api public
      def self.persist(hash, options = {})
        adapter = options.fetch(:adapter) { fail(UnknownAdapter, 'You did not specify an adapter for this Persistable Hash.'.freeze) }
        target  = options.fetch(:target) { fail(UnknownLocation, 'You did not specify where you want to persist this Persistable Hash.'.freeze) }

        adapter.write(target, hash)
      end

      # Register adapter namespace under a specified identifier.
      #
      # @param [Symbol] identifier
      # @param [Module] adapter
      #
      # @return [self]
      #
      # @api public
      def self.register_adapter(identifier, adapter)
        adapters[identifier] = adapter
        self
      end

      # Add the #persist method to a Hash.
      #
      # @api public
      module Persistence
        # Persist the Hash to the given store.
        #
        # @note When the Hash has previously been persisted, this can be
        #   called without a parameter to persist to the last location.
        #
        # @param [String, #write] store The path name or actual target to write to.
        #
        # @return [#read]
        #
        # @raise [ArgumentError] if the Hash was not previously persisted and
        #   file is nil
        def persist(store = nil)
          self.persistable_store = store unless store.nil?

          if persistable_store.nil?
            fail(UnknownLocation, 'You did not specify where you want to persist this Persistable Hash.'.freeze)
          else
            Persistable.persist(self, adapter: adapter, target: persistable_store)
            persistable_store
          end
        end

        private

        attr_reader :persistable_store

        # @api private
        def persistable_store=(store)
          if store.is_a? String
            @persistable_store = Pathname.new(store)
          else
            @persistable_store = store
          end
        end
      end
    end
  end
end

require 'hashie/extensions/persistable/json'
require 'hashie/extensions/persistable/yaml'
