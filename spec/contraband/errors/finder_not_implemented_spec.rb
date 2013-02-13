require 'spec_helper'

describe Contraband::Errors::FinderNotImplemented do

  let(:error) do
    described_class.new(TwitterImporter::Status)
  end

  subject(:message) do
    error.message
  end

  it 'contains the problem in the message' do
    expect(message).to include(
      'TwitterImporter::Status.find is not implemented.'
    )
  end

  it 'contains the summary in the message' do
    expect(message).to include(
      'it is expected that TwitterImporter::Status overrides .find to return an instantiated resource'
    )
  end

  it 'contains the resolution in the message' do
    expect(message).to include(
      'Implement TwitterImporter::Status.find.'
    )
  end
end