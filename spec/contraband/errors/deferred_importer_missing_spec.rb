require 'spec_helper'

describe Contraband::Errors::DeferredImporterMissing do

  let(:error) do
    described_class.new
  end

  subject(:message) do
    error.message
  end

  it 'contains the problem in the message' do
    expect(message).to include(
      'DeferredImport is not defined'
    )
  end

  it 'contains the summary in the message' do
    expect(message).to include(
      'requires a DeferredImport model'
    )
  end

  it 'contains the resolution in the message' do
    expect(message).to include(
      'Implement a DeferredImport model'
    )
  end
end