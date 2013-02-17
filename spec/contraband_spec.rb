require 'spec_helper'

describe Contraband do

  describe '.import' do

    it 'imports the provided resource through the model importer' do
      importer = double(Contraband::Importer)
      importer.should_receive(:import).with(id: '123', message: 'like dis if u cry evertiem')
      Status.should_receive(:importer_class).with(:facebook).and_return(importer)
      Contraband.import(Status, :facebook, id: '123', message: 'like dis if u cry evertiem')
    end
  end

  describe '.import_async' do

    context 'when DeferredImport is not defined' do

      it 'raises Errors::DeferredImporterMissing' do
        expect {
          Contraband.import_async(Status, :facebook, '123')
        }.to raise_error(Contraband::Errors::DeferredImporterMissing)
      end
    end

    context 'when DeferrredImport is defined' do

      it 'calls DeferredImport.import with model, service, id, and data' do
        deferred_importer = double('DeferredImport')
        deferred_importer.should_receive(:import).with(TwitterImporter::Status, '123', { foo: 'bar', baz: 'bloop' })
        stub_const('DeferredImport', deferred_importer)
        Contraband.import_async(Status, :twitter, '123', { foo: 'bar', baz: 'bloop' })
      end
    end
  end
end