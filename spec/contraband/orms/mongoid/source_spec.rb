require 'spec_helper'

describe Contraband::Mongoid::Source do

  let(:source_class) do
    Class.new do
      include Mongoid::Document
      include Contraband::Mongoid::Source
    end
  end

  let(:sourceful) do
    Status.new(
      message: 'Megan Fox plays herself in a Motorola commercial and still isn\'t convincing.',
      author: 'badbanana'
    )
  end

  subject do
    source_class
  end

  it { should have_field(:_id).of_type(String) }
  it { should have_field(:service).of_type(Symbol) }
  it { should have_field(:tracked_fields).of_type(Array).with_default_value_of([]) }

  it { should be_embedded_in(:sourceful) }

  describe '#untrack_changed_fields' do

    subject(:source) do
      source_class.new(tracked_fields: ['message', 'author'], sourceful: sourceful)
    end

    it 'removes changed fields from #tracked_fields' do
      source.untrack_changed_fields
      expect(source.tracked_fields).to be_empty
    end
  end

  describe '#track_changed_fields' do

    subject(:source) do
      source_class.new(sourceful: sourceful)
    end

    it 'adds changed fields to #tracked_fields' do
      source.track_changed_fields
      expect(source.tracked_fields).to include('message', 'author')
    end

    it 'only tracks present fields' do
      sourceful.message = nil
      expect(source.tracked_fields).to_not include('message')
    end

    it "removes changed fields from other sources' #tracked_fields" do
      source1 = sourceful.sources.build(tracked_fields: ['message'])
      source2 = sourceful.sources.build(tracked_fields: ['author'])
      source.track_changed_fields

      expect([source1, source2].collect(&:tracked_fields).sum).to be_empty
      expect(source.tracked_fields).to include('message', 'author')
    end
  end

  describe '#importer_class' do

    it 'returns the importer of the service and sourceful model' do
      sourceful = Status.new
      source = sourceful.add_source(:twitter, '123')
      expect(source.importer_class).to eq(TwitterImporter::Status)
    end
  end
end