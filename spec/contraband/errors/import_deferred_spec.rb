require 'spec_helper'

describe Contraband::Errors::ImportDeferred do

  let(:error) do
    described_class.new(TwitterImporter::Status)
  end

  subject(:message) do
    error.message
  end

  it 'contains the problem in the message' do
    expect(message).to include(
      'The import was deferred'
    )
  end

  it 'contains the summary in the message' do
    expect(message).to include(
      'import is halted and enqueued for deferred execution'
    )
  end

  it 'contains the resolution in the message' do
    expect(message).to include(
      'Please report issues at https://github.com/tabeso/contraband'
    )
  end
end