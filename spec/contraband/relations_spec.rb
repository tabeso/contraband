require 'spec_helper'

describe Contraband::Relations do

  subject(:importer_class) do
    Class.new(Contraband::Importer) do
      def self.service
        :amazon
      end
    end
  end

  describe '.belongs_to' do

    it 'adds relationship to importer relations' do
      importer_class.belongs_to :company
      expect(importer_class.relations).to include(:company)
    end

    it 'adds getter to importer' do
      importer_class.belongs_to :company
      expect(importer_class.new(nil)).to respond_to(:company)
    end

    it 'adds foreign key getter to importer' do
      importer_class.belongs_to :company
      expect(importer_class.new(nil)).to respond_to(:company_id)
    end
  end

  describe '.has_many' do

    it 'adds relationship to importer relations' do
      importer_class.has_many :products
      expect(importer_class.relations).to include(:products)
    end

    it 'adds getter to importer' do
      importer_class.has_many :products
      expect(importer_class.new(nil)).to respond_to(:products)
    end

    it 'adds foreign key getter to importer' do
      importer_class.has_many :products
      expect(importer_class.new(nil)).to respond_to(:product_ids)
    end
  end
end