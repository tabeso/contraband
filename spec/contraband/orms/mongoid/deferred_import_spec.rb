require 'spec_helper'

describe Contraband::Mongoid::DeferredImport do

  subject do
    DeferredImport
  end

  it { should have_field(:processor).of_type(String) }
  it { should have_field(:resource_id).of_type(String) }
  it { should have_field(:data).of_type(Hash).with_default_value_of({}) }

  it { should have_index_for(processor: 1, resource_id: 1) }

  describe 'validations' do

    it { should validate_presence_of(:processor) }
    it { should validate_presence_of(:data) }
    it { should validate_presence_of(:resource_id) }

    context 'when data is present' do

      subject(:import) do
        DeferredImport.new(processor: String, data: { message: 'I win.' })
      end

      it 'does not validate presence of resource identifier' do
        expect(import).to be_valid
        import.data = {}
        expect(import).to_not be_valid
      end
    end

    context 'when resource identifier is present' do

      subject(:import) do
        DeferredImport.new(processor: Struct, resource_id: '123')
      end

      it 'does not validate presence of data' do
        expect(import).to be_valid
        import.resource_id = nil
        expect(import).to_not be_valid
      end
    end
  end

  describe 'after create' do

    subject(:import) do
      DeferredImport.new(processor: TwitterImporter::Status, data: { foo: 'bar' })
    end

    it 'enqueues itself' do
      expect {
        import.save
      }.to change(Contraband.backgrounder.worker_class.jobs, :size).by(1)
      expect(Contraband.backgrounder.worker_class.jobs.last['args']).to eq([import.id.to_s])
    end
  end

  describe '.import' do

    it 'creates new DeferredImport with provided processor, id, and data' do
      import = DeferredImport.import(TwitterImporter::Status, '456', what: 'is', dis: 'i dont even')
      expect(import).to be_persisted
      expect(import.processor).to eq(TwitterImporter::Status)
      expect(import.resource_id).to eq('456')
      expect(import.data).to eq(what: 'is', dis: 'i dont even')
    end
  end

  describe '#import' do

    subject(:job) do
      DeferredImport.import(TwitterImporter::Status, '789', message: 'foo', author: 'bar')
    end

    context 'when successful' do

      before do
        job.processor.should_receive(:import).with(job.to_resource).and_return(true)
      end

      it 'returns true' do
        expect(job.import).to be_true
      end

      it 'destroys the record' do
        job.import
        expect(job).to be_destroyed
      end
    end

    context 'when unsuccessful' do

      before do
        job.processor.should_receive(:import).with(job.to_resource).and_return(false)
      end

      it 'returns false' do
        expect(job.import).to be_false
      end

      it 'does not destroy the record' do
        job.import
        expect(job).to_not be_destroyed
      end
    end
  end

  describe '#to_resource ' do

    subject(:import) do
      DeferredImport.new(processor: TwitterImporter::Status)
    end

    context 'when there is data' do

      it 'instantiates data through processor' do
        import.data = { foo: 'bar', baz: 'rawr' }
        resource = Hashie::Mash.new(import.data)
        import.processor.should_receive(:instantiate).with(import.data).and_return(resource)
        expect(import.to_resource).to eq(resource)
      end
    end

    context 'when there is no data' do

      it 'finds resource through processor' do
        import.resource_id = 'foo'
        import.processor.should_receive(:find).with('foo').and_return(:found_me)
        expect(import.to_resource).to eq(:found_me)
      end
    end
  end
end