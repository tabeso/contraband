require 'spec_helper'

describe Contraband::Errors::UninferableModel do

  let(:error) do
    described_class.new(TwitterImporter::Status)
  end

  subject(:message) do
    error.message
  end

  it 'contains the problem in the message' do
    expect(message).to include(
      'Could not infer model class from importer class TwitterImporter::Status.'
    )
  end

  it 'contains the summary in the message' do
    expect(message).to include(
      'TwitterImporter::Status is either named as <Service>Importer::<Model>'
    )

    expect(message).to include(
      'TwitterImporter::Status.model_class has been overridden'
    )
  end

  it 'contains the resolution in the message' do
    expect(message).to include(
      'Ensure the importer either follows the naming convention or defines .model_class'
    )
  end
end