require 'spec_helper'
require 'contraband/test/rspec_integration'

class ValidImporter < Contraband::Importer
  attribute :foo
end

class InvalidImporter < Contraband::Importer
end

[:have_attribute, :have_attributes].each do |method|

  describe "expect(actual).to #{method}(:key)" do

    it_behaves_like 'an RSpec matcher', valid_value: ValidImporter, invalid_value: InvalidImporter do

      let(:matcher) do
        send(method, :foo)
      end
    end

    it 'passes if target has attribute' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :foo
      expect(klass).to send(method, :foo)
    end

    it 'fails if target does not have attribute' do
      klass = Class.new(Contraband::Importer)
      expect {
        expect(klass).to send(method, :bar)
      }.to fail_with(/expected #<Class.*> to have attribute :bar/)
    end
  end

  describe "expect(actual).to #{method}(:key).as(:alias)" do

    it 'passes if target has attribute and alias' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :foo, as: :bar
      expect(klass).to send(method, :foo).as(:bar)
    end

    it 'fails if target does not have attribute' do
      klass = Class.new(Contraband::Importer)
      expect {
        expect(klass).to send(method, :bar).as(:foo)
      }.to fail_with(/expected #<Class.*> to have attribute :bar as :foo/)
    end

    it 'fails if target attribute does not have alias' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :rug, as: :mat
      expect {
        expect(klass).to send(method, :rug).as(:carpet)
      }.to fail_with(/expected #<Class.*> to have attribute :rug as :carpet/)
    end
  end

  describe "expect(actual).to #{method}(:key).with_priority(n)" do

    it 'passes if target has attribute and priority' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :money, priority: 1
      expect(klass).to send(method, :money).with_priority(1)
    end

    it 'fails if target does not have attribute' do
      klass = Class.new(Contraband::Importer)
      expect {
        expect(klass).to send(method, :money).with_priority(1)
      }.to fail_with(/expected #<Class.*> to have attribute :money with priority 1/)
    end

    it 'fails if target attribute does not have priority' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :money, priority: 2
      expect {
        expect(klass).to send(method, :money).with_priority(3)
      }.to fail_with(/expected #<Class.*> to have attribute :money with priority 3/)
    end
  end

  describe "expect(actual).to #{method}(:key).as(:alias).with_priority(n)" do

    it 'passes if target has attribute, alias, and priority' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :sweet, as: :sour, priority: 10
      expect(klass).to send(method, :sweet).as(:sour).with_priority(10)
    end

    it 'fails if target does not have attribute' do
      klass = Class.new(Contraband::Importer)
      expect {
        expect(klass).to send(method, :sweet).as(:sour).with_priority(10)
      }.to fail_with(/expected #<Class.*> to have attribute :sweet as :sour with priority 10/)
    end

    it 'fails if target attribute does not have alias' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :sweet, priority: 10
      expect {
        expect(klass).to send(method, :sweet).as(:sour).with_priority(10)
      }.to fail_with(/expected #<Class.*> to have attribute :sweet as :sour with priority 10/)
    end

    it 'fails if target attribute does not have priority' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :sweet, as: :sour
      expect {
        expect(klass).to send(method, :sweet).as(:sour).with_priority(10)
      }.to fail_with(/expected #<Class.*> to have attribute :sweet as :sour with priority 10/)
    end
  end

  describe "expect(actual).to #{method}(:key1, :key2)" do

    it 'passes if target has attributes' do
      klass = Class.new(Contraband::Importer)
      klass.attributes :foo, :bar
      expect(klass).to send(method, :foo, :bar)
    end

    it 'fails if target is missing first attribute' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :bar
      expect {
        expect(klass).to send(method, :foo, :bar)
      }.to fail_with(/expected #<Class.*> to have attributes :foo, :bar/)
    end

    it 'fails if target is missing second attribute' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :foo
      expect {
        expect(klass).to send(method, :foo, :bar)
      }.to fail_with(/expected #<Class.*> to have attributes :foo, :bar/)
    end
  end

  describe "expect(actual).to #{method}(:key1, :key2).with_priority(n)" do

    it 'passes if target has attributes and priority' do
      klass = Class.new(Contraband::Importer)
      klass.attributes :foo, :bar, priority: 5
      expect(klass).to send(method, :foo, :bar).with_priority(5)
    end

    it 'fails if target is missing first attribute' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :bar, priority: 5
    end

    it 'fails if target is missing second priority' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :foo, priority: 5
      expect {
        expect(klass).to send(method, :foo, :bar).with_priority(5)
      }.to fail_with(/expected #<Class.*> to have attributes :foo, :bar with priority 5/)
    end

    it 'fails if target attributes are missing priority' do
      klass = Class.new(Contraband::Importer)
      klass.attributes :foo, :bar
      expect {
        expect(klass).to send(method, :foo, :bar).with_priority(5)
      }.to fail_with(/expected #<Class.*> to have attributes :foo, :bar with priority 5/)
    end

    it 'fails if target is missing first attribute priority' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :foo
      klass.attribute :bar, priority: 5
      expect {
        expect(klass).to send(method, :foo, :bar).with_priority(5)
      }.to fail_with(/expected #<Class.*> to have attributes :foo, :bar with priority 5/)
    end

    it 'fails if target is missing second attribute priority' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :foo, priority: 5
      klass.attribute :bar
      expect {
        expect(klass).to send(method, :foo, :bar).with_priority(5)
      }.to fail_with(/expected #<Class.*> to have attributes :foo, :bar with priority 5/)
    end
  end

  describe "expect(actual).to_not #{method}(:key)" do

    it 'passes if target does not have attribute' do
      klass = Class.new(Contraband::Importer)
      expect(klass).to_not send(method, :foo)
    end

    it 'fails if target has attribute' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :foo
      expect {
        expect(klass).to_not send(method, :foo)
      }.to fail_with(/expected #<Class.*> not to have attribute :foo/)
    end
  end

  describe "expect(actual).to_not #{method}(:key1, key2)" do

    it 'passes if target does not have attributes' do
      klass = Class.new(Contraband::Importer)
      expect(klass).to_not send(method, :foo, :bar)
    end

    it 'fails if target has attributes' do
      klass = Class.new(Contraband::Importer)
      klass.attributes :foo, :bar
      expect {
        expect(klass).to_not send(method, :foo, :bar)
      }.to fail_with(/expected #<Class.*> not to have attributes :foo, :bar/)
    end

    it 'fails if target has first attribute' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :foo
      expect {
        expect(klass).to_not send(method, :foo, :bar)
      }.to fail_with(/expected #<Class.*> not to have attributes :foo, :bar/)
    end

    it 'fails if target has second attribute' do
      klass = Class.new(Contraband::Importer)
      klass.attribute :bar
      expect {
        expect(klass).to_not send(method, :foo, :bar)
      }.to fail_with(/expected #<Class.*> not to have attributes :foo, :bar/)
    end
  end
end