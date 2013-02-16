require 'spec_helper'

describe Contraband::Importer do

  subject(:importer) do
    Class.new(Contraband::Importer)
  end

  describe '.model_class' do

    context 'when model can be inferred' do

      it 'returns the class of the model' do
        importer.should_receive(:name).and_return('SomeServiceImporter::String')
        expect(importer.model_class).to eq(String)
      end
    end

    context 'when model cannot be inferred' do

      it 'raises Errors::UninferableModel' do
        importer.should_receive(:name).twice.and_return('Teehee')
        expect {
          importer.model_class
        }.to raise_error(Contraband::Errors::UninferableModel)
      end
    end
  end

  describe '.service' do

    context 'when service can be inferred' do

      it 'returns the service of the importer' do
        importer.should_receive(:name).and_return('SomeServiceImporter::String')
        expect(importer.service).to eq(:some_service)
      end
    end

    context 'when service cannot be inferred' do

      it 'raises Errors::UninferableService' do
        importer.should_receive(:name).twice.and_return('Blah')
        expect {
          importer.service
        }.to raise_error(Contraband::Errors::UninferableService)
      end
    end
  end

  describe '.instantiate' do

    context 'by default' do

      let(:data) do
        { 'id' => '123', 'foo' => 'bar', 'baz' => 'bloop' }
      end

      it 'wraps the provided data in a Hashie::Mash' do
        expect(importer.instantiate(data)).to be_a(Hashie::Mash)
      end

      it 'matches original hash' do
        expect(importer.instantiate(data)).to eq(data)
      end
    end
  end

  describe '.find' do

    context 'by default' do

      it 'raises Errors::FinderNotImplemented' do
        expect {
          importer.find('123')
        }.to raise_error(Contraband::Errors::FinderNotImplemented)
      end
    end
  end

  describe '#initialize' do

    it 'initializes with a resource' do
      expect(importer.new('bar').resource).to eq('bar')
    end
  end

  describe '#logger' do

    it 'returns Contraband.logger' do
      Contraband.should_receive(:logger).and_return(:foo)
      expect(importer.new(nil).logger).to eq(:foo)
    end
  end

  describe '#service' do

    it 'returns .service' do
      importer.should_receive(:service).and_return(:buzzz)
      expect(importer.new(nil).service).to eq(:buzzz)
    end
  end

  describe '#model_class' do

    it 'returns .model_class' do
      importer.should_receive(:model_class).and_return(String)
      expect(importer.new(nil).model_class).to eq(String)
    end
  end
end