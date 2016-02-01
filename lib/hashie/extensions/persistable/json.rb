require 'json'

module Hashie
  module Extensions
    module Persistable
      # Persistable adapter that serializes a Hash to a JSON file.
      #
      # @example
      #   class PersistableHash < Hash
      #     include Hashie::Extensions::Persistable.new(adapter: :json)
      #   end
      #
      #   data = PersistableHash[test: 'value']
      #   data.persist('data.json')
      module Json
        # Accessor method for an instance of the JSON Adapter.
        #
        # @api private
        def adapter
          Adapter.new
        end

        # Class that handles serializing a Hash to a JSON file.
        #
        # @api public
        class Adapter
          # Load a hash from a JSON source.
          #
          # @param [#read, #to_io, #to_str] source The source to load from.
          #
          # @return [Hash]
          #
          # @api public
          def load(source)
            ::JSON.load(source)
          end

          # Write a hash to the JSON file.
          #
          # @param [#write] target
          # @param [Hash] hash
          #
          # @return [#read]
          #
          # @api public
          def write(target, hash)
            target.write(::JSON.dump(hash))
            target
          end
        end
      end
    end
  end
end

Hashie::Extensions::Persistable.register_adapter(:json, Hashie::Extensions::Persistable::Json)
