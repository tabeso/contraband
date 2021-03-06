require 'spec_helper'

describe Contraband::Processing do

  let(:importer_class) do
    TwitterImporter::Status
  end

  let(:resource) do
    importer_class.instantiate(
      id: '123',
      message: 'This is a tweet.',
      author: 'Captain Obvious'
    )
  end

  subject(:importer) do
    importer_class.new(resource)
  end

  describe '.import' do

    it 'initializes importer with provided resource' do
      importer_class.should_receive(:new).with(resource).and_return(double(
        importer_class, import: true
      ))
      importer_class.import(resource)
    end

    it 'calls #import on the initialized importer' do
      importer.should_receive(:import)
      importer_class.should_receive(:new).with(resource).and_return(importer)
      importer_class.import(resource)
    end

    it 'returns the result of #import' do
      importer_class.any_instance.should_receive(:import).and_return(:bar)
      expect(importer_class.import(resource)).to eq(:bar)
    end
  end

  describe '.import_async' do

    context 'when DeferredImport is not defined' do

      before do
        DeferredImport
        Object.send(:remove_const, :DeferredImport)
      end

      after do
        require 'dummy/app/models/deferred_import'
      end

      it 'raises Errors::DeferredImporterMissing' do
        expect {
          importer_class.import_async('123')
        }.to raise_error(Contraband::Errors::DeferredImporterMissing)
      end
    end

    context 'when DeferredImport is defined' do

      it 'calls DeferredImport.import with self, id, and data' do
        deferred_importer = double('DeferredImport')
        deferred_importer.should_receive(:import).with(TwitterImporter::Status, '123', { foo: 'bar', baz: 'bloop' })
        stub_const('DeferredImport', deferred_importer)
        importer_class.import_async('123', { foo: 'bar', baz: 'bloop' })
      end
    end
  end

  describe '#import' do

    it 'calls #process_attributes' do
      importer.should_receive(:process_attributes)
      importer.model.should_receive(:changed?).and_return(false)
      importer.import
    end

    context 'when model has changed' do

      it 'calls #save' do
        importer.model.should_receive(:changed?).and_return(true)
        importer.should_receive(:save)
        importer.import
      end

      it 'returns the result of #save' do
        importer.model.should_receive(:changed?).and_return(true)
        importer.should_receive(:save).and_return(:foo)
        expect(importer.import).to eq(:foo)
      end
    end

    context 'when model has not changed' do

      it 'returns true' do
        importer.model.should_receive(:changed?).and_return(false)
        expect(importer.import).to be_true
      end

      it 'does not call #save' do
        importer.model.should_receive(:changed?).and_return(false)
        importer.should_not_receive(:changed?)
        expect(importer.import).to be_true
      end
    end
  end

  describe '#process_attributes' do

    it 'assigns each assignable attribute on the model' do
      importer.send(:process_attributes)
      expect(importer.model.attributes).to include(
        'message' => 'This is a tweet.',
        'author'  => 'Captain Obvious'
      )
    end
  end

  describe '#save' do

    context 'when model responds to :save_with' do

      it 'saves model with the importer service and resource identifier' do
        importer.model.should_receive(:respond_to?).with(:save_with).and_return(true)
        importer.model.should_receive(:save_with).with(importer.service, importer.id)
        importer.send(:save)
      end
    end

    context 'when model does not respond to :save_with' do

      it 'saves model normally' do
        importer.model.should_receive(:respond_to?).with(:save_with).and_return(false)
        importer.model.should_receive(:save)
        importer.send(:save)
      end
    end
  end

  describe '#model' do

    it 'finds or initializes the model by its source identifier and service' do
      importer_class.model_class.
        should_receive(:find_or_initialize_by_source_id_and_service).
        with('123', :twitter)
      importer.model
    end

    it 'caches the found or initialized model' do
      importer_class.model_class.
        should_receive(:find_or_initialize_by_source_id_and_service).
        with('123', :twitter).and_return(Status.new)

      expect(importer.model.object_id).to eq(importer.model.object_id)
    end
  end
end