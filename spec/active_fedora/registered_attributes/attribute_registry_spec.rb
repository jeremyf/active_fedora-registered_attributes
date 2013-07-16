require 'spec_helper'
require "active_fedora/registered_attributes/attribute_registry"

describe ActiveFedora::RegisteredAttributes::AttributeRegistry do
  let(:context) { ActiveFedora::Base }
  let(:name) { "My Name" }
  let(:options) { {} }
  subject { ActiveFedora::RegisteredAttributes::AttributeRegistry.new(context) }

  describe '#register' do
    it 'yields an attribute' do
      @name = nil
      subject.register(name, options) do |attribute|
        @name = attribute.name
      end
      expect(@name).to eq(name)
    end
    it 'stores the attribute' do
      subject.register(name, options)
      expect(subject.fetch(name)).to be_kind_of(ActiveFedora::RegisteredAttributes::Attribute)
    end
  end
  describe 'editable and displayable attributes' do
    let(:editable_options) { { editable: true, displayable: false } }
    let(:displayable_options) { { editable: false, displayable: true } }
    let(:default_options) { {} }

    before(:each) do
      @editable_attribute = subject.register('editable', editable_options)
      @displayable_attribute = subject.register('displayable', displayable_options)
      @default_attribute = subject.register('default', default_options)
    end
    it 'has #editable_attributes derived from registered inputs' do
      expect(subject.editable_attributes).to eq([@editable_attribute, @default_attribute])
    end
    it 'has #displayable_attributes derived from registered inputs' do
      expect(subject.displayable_attributes).to eq([@displayable_attribute, @default_attribute])
    end
  end
  describe '#attribute_defaults' do
    let(:context) { double }
    let(:default_options) { { default: '1234' } }
    let(:default_field_name) { 'something' }
    it "assigns default on registry's context context" do
      subject.register(default_field_name, default_options)
      expect(subject.attribute_defaults).to eq([[default_field_name, default_options.fetch(:default)]])
    end
  end
  describe '#input_options_for' do
    let(:editable_options) { { editable: true, displayable: false, multiple: true } }

    before(:each) do
      @editable_attribute = subject.register('editable', editable_options)
    end

    it "returns input options for existing attribute" do
      expect(subject.input_options_for('editable')).to eq({as: "multi_value",input_html: {multiple:"multiple"}})
    end

    it "returns default options for existing attribute" do
      options = {hello: :world}
      expect(subject.input_options_for('hello', options)).to eq(options)
    end
  end
  describe '#label_for' do
    let(:label_options) { { label: "Hello World" } }
    let(:field_name) { 'thing' }

    before(:each) do
      subject.register(field_name, label_options)
    end

    it "handles label for existing field" do
      expect(subject.label_for(field_name)).to eq(label_options.fetch(:label))
    end

    it "handles missing field's label" do
      expect(subject.label_for("hydra_field")).to eq("Hydra Field")
    end
  end
end
