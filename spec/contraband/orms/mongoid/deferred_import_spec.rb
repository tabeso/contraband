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

    context 'when data is present' do

      it 'enqueues itself through Contraband::ImportWorker' do
        pending
      end
    end

    context 'when data is not present' do

      it 'enqueues itself through ThrottledImportWorker' do
        pending
      end
    end
  end

  describe '.import' do

    let(:import) do
      DeferredImport.last
    end

    context 'when supplied data' do

      it 'creates with the processor and data' do
        pending
      end
    end

    context 'when supplied a resource identifier' do

      it 'creates with the processor and resource identifier' do
        pending
      end
    end

    describe '#import' do

      context 'when successful' do

        it 'returns true' do
          pending
        end

        it 'destroys the record' do
          pending
        end
      end

      context 'when unsuccessful' do

        it 'returns false' do
          pending
        end

        it 'does not destroy the record' do
          pending
        end
      end
    end
  end

  describe '#processor=' do

    it 'stringifies the class name' do
      pending
    end
  end

  describe '#processor' do

    it 'constantizes the stored string' do
      pending
    end
  end

  describe '#to_resource ' do

    context 'when there is data' do

      pending
    end

    context 'when there is no data' do

      pending
    end
  end
end