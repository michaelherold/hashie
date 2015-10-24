require 'yaml'

module Hashie
  module Extensions
    module Persistable
      # Persistable adapter that serializes a Hash to a YAML file.
      #
      # @example
      #   class PersistableHash < Hash
      #     include Hashie::Extensions::Persistable.new(adapter: :yaml)
      #   end
      #
      #   data = PersistableHash[test: 'value']
      #   data.persist('data.yml')
      module Yaml
        # Accessor method for an instance of the YAML Adapter.
        #
        # @api private
        def adapter
          Adapter.new
        end

        # Class that handles serializing a Hash to a YAML file.
        #
        # @api public
        class Adapter
          # Load a hash from a YAML source.
          #
          # @param [#read, #to_io, #to_str] source The source to load from.
          #
          # @return [Hash]
          #
          # @api public
          def load(source)
            ::YAML.load(source)
          end

          # Write a hash to the YAML file.
          #
          # @param [#write] target
          # @param [Hash] hash
          #
          # @return [#read]
          #
          # @api public
          def write(target, hash)
            target.write(::YAML.dump(hash.to_h))
            target
          end
        end
      end
    end
  end
end

Hashie::Extensions::Persistable.register_adapter(:yaml, Hashie::Extensions::Persistable::Yaml)
