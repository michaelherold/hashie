require 'spec_helper'

RSpec.describe Hashie::Extensions::Persistable do
  describe '.load' do
    let(:full_options) { { adapter: adapter } }
    let(:options) { full_options }

    subject { Hashie::Extensions::Persistable.load(source, options) }

    context 'with a JSON adapter' do
      let(:adapter) { Hashie::Extensions::Persistable::Json::Adapter.new }
      let(:source) { StringIO.new('{"test":"value"}') }

      it 'loads the source' do
        expect(subject).to eq('test' => 'value')
      end
    end

    context 'with a YAML adapter' do
      let(:adapter) { Hashie::Extensions::Persistable::Yaml::Adapter.new }
      let(:source) { StringIO.new("---\ntest: value\n") }

      it 'loads the source' do
        expect(subject).to eq('test' => 'value')
      end
    end
  end

  describe '.persist' do
    let(:adapter) { Hashie::Extensions::Persistable::Json::Adapter.new }
    let(:hash) { { 'test' => 'value' } }
    let(:store) { StringIO.new }
    let(:full_options) { { adapter: adapter, target: store } }
    let(:options) { full_options }

    subject { Hashie::Extensions::Persistable.persist(hash, options) }

    it 'persists the hash to the store in a JSON format' do
      subject
      store.rewind
      expect(store.read).to eq '{"test":"value"}'
    end

    context 'without an adapter' do
      let(:options) { full_options.reject { |k, _| k == :adapter } }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error Hashie::Extensions::Persistable::UnknownAdapter
      end
    end

    context 'without a target' do
      let(:options) { full_options.reject { |k, _| k == :target } }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error Hashie::Extensions::Persistable::UnknownLocation
      end
    end
  end

  context 'when included plainly' do
    class UnconfiguredPersistableHash < Hash
      include Hashie::Extensions::Persistable
    end

    subject(:hash) { UnconfiguredPersistableHash['test' => 'value'] }

    it { is_expected.to respond_to :persist }

    describe '#adapter' do
      subject { hash.adapter }

      it { is_expected.to be_a Hashie::Extensions::Persistable::Json::Adapter }
    end
  end

  context 'when included as a built module' do
    context 'without any configuration' do
      class PersistableHash < Hash
        include Hashie::Extensions::Persistable.new
      end

      subject(:hash) { PersistableHash['test' => 'value'] }

      it { is_expected.to respond_to :persist }

      describe '#adapter' do
        subject { hash.adapter }

        it { is_expected.to be_a Hashie::Extensions::Persistable::Json::Adapter }
      end

      describe '#persist' do
        let(:store) { StringIO.new }

        subject { hash.persist(store) }

        it 'persists the hash to the store in a JSON format' do
          subject
          store.rewind
          expect(store.read).to eq '{"test":"value"}'
        end

        context 'with a String path for the store' do
          let(:file) { Tempfile.new('string-test.json') }
          let(:store) { file.path }

          it 'persists the hash to the file stored at the path' do
            subject
            file.rewind
            expect(file.read).to eq '{"test":"value"}'
          end
        end

        context 'without a store' do
          subject { hash.persist }

          it 'raises an ArgumentError' do
            expect { subject }.to raise_error Hashie::Extensions::Persistable::UnknownLocation
          end

          context 'after the hash was previously persisted' do
            before { hash.persist(StringIO.new) }

            it 'does not raise an ArgumentError' do
              expect { subject }.not_to raise_error
            end
          end
        end
      end
    end

    context 'with a configured persist method' do
      class PersistableHashWithSave < Hash
        include Hashie::Extensions::Persistable.new(persist_method: :save)
      end

      subject { PersistableHashWithSave['test' => 'value'] }

      it { is_expected.to respond_to :save }
      it { is_expected.not_to respond_to :persist }
    end

    context 'with a configured adapter' do
      class PersistableHashWithYamlAdapter < Hash
        include Hashie::Extensions::Persistable.new(adapter: :yaml)
      end

      subject(:hash) { PersistableHashWithYamlAdapter['test' => 'value'] }

      describe '#adapter' do
        subject { hash.adapter }

        it { is_expected.to be_a Hashie::Extensions::Persistable::Yaml::Adapter }
      end

      describe '#persist' do
        let(:store) { StringIO.new }

        subject { hash.persist(store) }

        it 'persists the hash to the store in a YAML format' do
          subject
          store.rewind
          expect(store.read).to eq "---\ntest: value\n"
        end
      end
    end
  end
end
