require 'spec_helper'

describe Contraband::Errors::UninferableImporter do

  let(:error) do
    described_class.new(:twitter, Status)
  end

  subject(:message) do
    error.message
  end

  it 'contains the problem in the message' do
    expect(message).to include(
      'Could not infer importer class for :twitter from model class Status.'
    )
  end

  it 'contains the summary in the message' do
    expect(message).to include(
      'it is expected that a class exists with the name TwitterImporter::Status'
    )

    expect(message).to include(
      'Status.importer_class has been overridden'
    )
  end

  it 'contains the resolution in the message' do
    expect(message).to include(
      'Ensure the importer exists and is loaded or the model has overridden .importer_class'
    )
  end
end