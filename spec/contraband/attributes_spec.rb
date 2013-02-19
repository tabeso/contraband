require 'spec_helper'

describe Contraband::Attributes do

  subject(:importer) do
    Class.new(Contraband::Importer)
  end

  describe '.attributes' do

    context 'when a single attribute is specified' do

      it 'adds the attribute' do
        importer.attributes :foo
        expect(importer.attributes).to eq(foo: Contraband::Attribute.new(:foo, 1))
      end
    end

    context 'when when multiple attributes are specified' do

      it 'adds each attribute' do
        importer.attributes :foo, :bar, :baz
        expect(importer.attributes).to eq(
          foo: Contraband::Attribute.new(:foo, 1),
          bar: Contraband::Attribute.new(:bar, 1),
          baz: Contraband::Attribute.new(:baz, 1)
        )
      end
    end

    context 'when no attributes are specified' do

      let(:attributes) do
        { foo: { priority: 1 } }
      end

      before do
        importer.instance_variable_set(:@attributes, attributes)
      end

      it 'returns the defined attributes' do
        expect(importer.attributes).to eq(attributes)
      end
    end

    context 'when a priority is specified' do

      it 'adds the attributes with the specified priority' do
        importer.attributes :tom, :dick, priority: 5
        importer.attributes :harry, priority: 2

        expect(importer.attributes).to eq(
          tom: Contraband::Attribute.new(:tom, 5),
          dick: Contraband::Attribute.new(:dick, 5),
          harry: Contraband::Attribute.new(:harry, 2)
        )
      end
    end
  end

  describe '.attribute' do

    it 'adds the specified attribute' do
      importer.attribute :frenzy
      expect(importer.attributes).to eq(
        frenzy: Contraband::Attribute.new(:frenzy, 1)
      )
    end

    it 'adds a getter for the attribute' do
      importer.attribute :name
      expect(importer.new(nil)).to respond_to(:name)
    end

    it 'adds an assignable checker for the attribute' do
      importer.attribute :number
      expect(importer.new(nil)).to respond_to(:can_assign_number?)
    end

    it 'strips trailing question marks from keys' do
      importer.attribute :frenzied?
      expect(importer.attributes[:frenzied?].key).to eq(:frenzied)
    end

    context 'when an alias is specified' do

      it 'does not make any changes to the key' do
        importer.attribute :frenzied?, as: :awesome?
        expect(importer.attributes[:frenzied?].key).to eq(:awesome?)
      end
    end

    context 'when a priority is specified' do

      it 'sets the provided priority on the attribute' do
        importer.attribute :cheeseburger, priority: 7
        expect(importer.attributes[:cheeseburger].priority).to eq(7)
      end
    end
  end

  describe '.has_attribute?' do

    context 'when the attribute is present' do

      it 'returns true' do
        importer.attribute :googles
        expect(importer).to have_attribute(:googles)
      end
    end

    context 'when the attribute is not present' do

      it 'returns false' do
        expect(importer).to_not have_attribute(:goggles)
      end
    end
  end

  describe '.priority_of' do

    it 'returns the priority of the attribute' do
      importer.attribute :bananas, priority: 5
      expect(importer.priority_of(:bananas)).to eq(5)
    end

    context 'when the attribute does not exist' do

      it 'returns nil' do
        expect(importer.priority_of(:sanity)).to eq(nil)
      end
    end
  end

  describe '#attributes' do

    it 'delegates to self.class' do
      importer.attribute :winning
      expect(importer.new(nil).attributes).to eq(importer.attributes)
    end
  end

  describe '#priority_of' do

    it 'delegates to self.class' do
      importer.attribute :losing
      expect(importer.new(nil).priority_of(:losing)).to eq(importer.priority_of(:losing))
    end
  end

  describe '#can_assign?' do

    context 'when attribute is not defined' do

      it 'returns false' do
        expect(importer.new(nil).can_assign?(:foo)).to be_false
      end
    end

    context 'when model responds to can_assign?' do

      it 'returns the result of model.can_assign?' do
        importer.attribute :title

        model = double('model')
        model.should_receive(:respond_to?).with(:can_assign?).and_return(true)
        model.should_receive(:can_assign?).with(:bar, :title).and_return(:foo)
        importer.any_instance.should_receive(:service).once.and_return(:bar)
        importer.any_instance.should_receive(:model).twice.and_return(model)

        expect(importer.new(nil).can_assign?(:title)).to eq(:foo)
      end
    end

    context 'when model does not respond to can_assign?' do

      it 'returns true' do
        importer.attribute :location

        model = double('model')
        model.should_receive(:respond_to?).with(:can_assign?).and_return(false)
        importer.any_instance.should_receive(:model).once.and_return(model)

        expect(importer.new(nil).can_assign?(:location)).to be_true
      end
    end
  end

  describe '#assignable_attributes' do

    let(:model) do
      Class.new do
        def self.can_assign?(service, attr)
          case attr
          when :foo, :bar
            true
          else
            false
          end
        end
      end
    end

    it 'returns every assignable attribute' do
      importer.attributes :foo, :bar, :baz
      importer.any_instance.should_receive(:service).at_least(1).times.and_return(:bar)
      importer.any_instance.should_receive(:model).at_least(1).times.and_return(model)

      expect(importer.new(nil).assignable_attributes).to eq([:foo, :bar])
    end
  end

  describe '#id' do

    context 'by default' do

      it 'returns resource.id' do
        model = double('model')
        model.should_receive(:id).and_return('something')
        expect(importer.new(model).id).to eq('something')
      end
    end
  end
end