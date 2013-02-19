require 'spec_helper'

describe Contraband::Mongoid::Sourceful do

  let(:sourceful_class) do
    Status
  end

  subject(:sourceful) do
    sourceful_class.new(message: 'this is a status update', author: 'John Wayne')
  end

  it { should embed_many(:sources) }

  it 'indexes embedded sources' do
    expect(sourceful).to have_index_for('sources._id' => 1, 'sources.service' => 1)
  end

  describe 'before validation' do

    it 'drops duplicate sources' do
      sourceful = sourceful_class.new
      3.times do
        sourceful.sources.build do |source|
          source._id = '123'
          source.service = :lastfm
        end
      end

      expect(sourceful).to be_valid
      expect(sourceful.sources.length).to eq(1)
    end
  end

  describe 'validations' do

    it 'validates uniqueness of sources' do
      existing = sourceful_class.new(message: 'foo', author: 'bar')
      existing.save_with(:twitter, '123')

      sourceful = sourceful_class.new(message: 'first!', author: 'JoeBlow')
      expect(sourceful.save_with(:twitter, '123')).to be_false
      expect(sourceful.errors[:sources]).to include('is invalid')
    end
  end

  describe '.by_source' do

    it 'scopes documents to provided service' do
      expect { sourceful.save_with(:facebook, '456') }.to change {
        sourceful_class.by_source(:facebook).count
      }.by(1)
    end

    it 'excludes documents that do not match provided service' do
      expect { sourceful.save }.not_to change {
        sourceful_class.by_source(:facebook).count
      }
    end
  end

  describe '.find_or_initialize_by_source_id_and_service' do

    context 'when existing' do

      it 'returns the document with matching source identifier and service' do
        existing = sourceful_class.new(message: 'wat')
        existing.save_with(:facebook, '123')
        found = sourceful_class.find_or_initialize_by_source_id_and_service('123', :facebook)
        expect(found).to eq(existing)
        expect(found.sources).to eq(existing.sources)
      end
    end

    context 'when non-existent' do

      it 'returns a new document with matching source identifier and service' do
        document = sourceful_class.find_or_initialize_by_source_id_and_service('456', :twitter)
        expect(document).to be_new_record
        expect(document.sources.size).to eq(1)
        expect(document.sources.first.id).to eq('456')
        expect(document.sources.first.service).to eq(:twitter)
      end
    end
  end

  describe '#add_source' do

    context 'when source does not exist' do

      it 'increments number of sources' do
        expect {
          sourceful.add_source(:identica, '789')
        }.to change(sourceful.sources, :size).by(1)
      end

      it 'adds source with provided service' do
        sourceful.add_source(:identica, '789')
        expect(sourceful.sources.first.service).to eq(:identica)
      end

      it 'adds source with provided identifier' do
        sourceful.add_source(:identica, '789')
        expect(sourceful.sources.first.id).to eq('789')
      end

      it 'returns source' do
        expect(sourceful.add_source(:identica, '789')).to be_a(Source)
      end
    end

    context 'when source exists' do

      before do
        sourceful.save_with(:twitter, '234')
      end

      it 'does not increment number of sources' do
        expect {
          sourceful.add_source(:twitter, '567')
        }.not_to change(sourceful.sources, :size)
      end

      it 'updates source identifier' do
        sourceful.add_source(:twitter, '123')
        expect(sourceful.sources.first.id).to eq('123')
      end

      it 'returns source' do
        expect(sourceful.add_source(:twitter, '234')).to be_a(Source)
      end
    end
  end

  describe '#save_with' do

    it 'saves the document' do
      sourceful.save_with(:bananas, '123')
      expect(sourceful).to be_persisted
    end

    context 'when document is existing' do

      before do
        sourceful.save_with(:myspace, '456')
      end

      context 'when document has existing source' do

        it 'touches source updated_at' do
          last_updated = sourceful.source_by_name(:myspace).updated_at
          sourceful.save_with(:myspace)
          expect(sourceful.source_by_name(:myspace).updated_at).to be > last_updated
        end
      end

      context 'when document does not have existing source' do

        it 'adds source with provided source and identifier' do
          sourceful.save_with(:twitter, '789')
          expect(sourceful.source_by_name(:twitter).id).to eq('789')
        end

        context 'when source identifier is not provided' do

          it 'raises ArgumentError' do
            expect {
              sourceful.save_with(:identica)
            }.to raise_error(ArgumentError)
          end

          it 'does not save the document' do
            sourceful.should_not_receive(:save)
            sourceful.save_with(:identica) rescue nil
            expect(sourceful).to be_changed
          end
        end
      end
    end
  end

  describe '#tracked_sources' do

    it 'returns an array of services attached to the model' do
      sourceful.save_with(:facebook, '123')
      sourceful.save_with(:lastfm, '456')
      expect(sourceful.tracked_sources).to eq([:facebook, :lastfm])
    end
  end

  describe '#can_assign?' do

    context 'when there are no sources' do

      it 'returns true' do
        expect(sourceful.can_assign?(:twitter, :message)).to be_true
      end
    end

    context 'when there are multiple sources' do

      context 'when service has higher priority' do

        context 'when lower priority service tracks field' do

          it 'returns true' do
            sourceful.save_with(:facebook, '123')
            expect(sourceful.can_assign?(:twitter, :author)).to be_true
          end
        end

        context 'when no other service tracks field' do

          it 'returns true' do
            sourceful.save_with(:twitter, '456')
            expect(sourceful.can_assign?(:twitter, :message)).to be_true
          end
        end
      end

      context 'when service has lower priority' do

        context 'when higher priority service tracks field' do

          it 'returns false' do
            sourceful.save_with(:twitter, '456')
            expect(sourceful.can_assign?(:facebook, :author)).to be_false
          end
        end

        context 'when no other service tracks field' do

          it 'returns true' do
            expect(sourceful.can_assign?(:facebook, :message)).to be_true
          end
        end
      end
    end
  end

  describe '#tracked_fields_by_source' do

    it 'returns an array of fields tracked by the source' do
      source = mock(Source, tracked_fields: %w(foo bar baz))
      sourceful.should_receive(:source_by_name).with(:facebook).and_return(source)
      expect(sourceful.tracked_fields_by_source(:facebook)).to eq([:foo, :bar, :baz])
    end
  end

  describe '#field_sources' do

    it 'returns a hash of sources and their tracked fields' do
      sourceful.should_receive(:tracked_sources).and_return([:eventful, :lastfm])
      sourceful.should_receive(:tracked_fields_by_source).with(:eventful).and_return([:flapjacks, :sausages])
      sourceful.should_receive(:tracked_fields_by_source).with(:lastfm).and_return([:biscuits, :gravy])

      expect(sourceful.field_sources).to eq({
        eventful: [:flapjacks, :sausages],
        lastfm: [:biscuits, :gravy]
      })
    end
  end
end