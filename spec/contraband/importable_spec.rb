require 'spec_helper'

describe Contraband::Importable do

  subject(:model) do
    Class.new do
      include Contraband::Importable
    end
  end

  describe '.importer_class' do

    context 'when importer can be inferred' do

      it 'returns the class of the model' do
        stub_const('SomeServiceImporter::SomeModel', Class.new)
        model.should_receive(:name).and_return('SomeModel')
        expect(model.importer_class(:some_service)).to eq(SomeServiceImporter::SomeModel)
      end
    end

    context 'when importer cannot be inferred' do

      it 'raises Errors::UninferableImporter' do
        model.should_receive(:name).twice.and_return('Teehee')
        expect {
          model.importer_class(:lame_joke)
        }.to raise_error(Contraband::Errors::UninferableImporter)
      end
    end
  end

  describe '.import' do

    it 'calls Contraband.import with itself, the provided service, and resource' do
      Contraband.should_receive(:import).with(model, :amazon, { foo: 'baz', bar: 'foo', baz: 'bar' })
      model.import(:amazon, { foo: 'baz', bar: 'foo', baz: 'bar' })
    end
  end
end