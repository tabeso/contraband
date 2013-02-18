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

    it 'passes provided identifier and data to Contraband::Importer.import_async' do
      TwitterImporter::Status.should_receive(:import_async).with(
        '123', message: 'i just ate a sandwich'
      )
      Contraband.import_async(Status, :twitter, '123', message: 'i just ate a sandwich')
    end
  end
end