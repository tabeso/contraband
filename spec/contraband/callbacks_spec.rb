require 'spec_helper'

describe Contraband::Callbacks do

  describe 'included' do

    subject(:importer) do
      Class.new(Contraband::Importer) do
        before_import :before_import_stub
        after_import :after_import_stub

        def before_import_stub
          true
        end

        def after_import_stub
          true
        end
      end
    end

    it 'includes the before_import callback' do
      expect(importer).to respond_to(:before_import)
    end

    it 'includes the after_import callback' do
      expect(importer).to respond_to(:after_import)
    end
  end

  describe '.before_import' do

    context 'when importing' do

      context 'when callback returns true' do

        it 'imports the resource' do
          pending
        end
      end

      context 'when callback returns false' do

        it 'does not import the resource' do
          pending
        end
      end
    end
  end

  describe '.after_import' do

    context 'when imported' do

      it 'executes the callback' do
        pending
      end
    end
  end
end