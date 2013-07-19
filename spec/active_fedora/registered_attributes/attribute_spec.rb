require 'spec_helper'
require "active_fedora/registered_attributes/attribute"

describe ActiveFedora::RegisteredAttributes::Attribute do
  let(:context) { Book }
  let(:field_name) { :title }
  let(:datastream) { 'properties' }
  let(:validation_options) {{ presence: true }}
  let(:options) {
    {
      datastream: datastream, hint: 'Your title',
      form: { input_html: {style: 'title-picker'}},
      multiple: true,
      displayable: displayable,
      editable: editable,
      default: default_value,
      validates: validation_options
    }
  }
  let(:displayable) { true }
  let(:editable) { true }
  let(:default_value) { nil }
  subject { ActiveFedora::RegisteredAttributes::Attribute.new(context, field_name, options) }

  describe '#displayable?' do
    its (:displayable?) { should == displayable }
  end

  describe '#editable?' do
    its (:editable?) { should == editable }
  end

  describe '#label' do
    describe 'with explicit model level label' do
      it 'uses the explicit label' do
        expect(subject.label).to eq(field_name.to_s.titleize)
      end
    end

    describe 'with inferred field' do
      let(:field_name) { 'internationalized_field' }
      it 'uses the explicit label' do
        expect(subject.label).to eq('Internationalized field')
      end
    end
  end

  describe '#with_delegation_options' do
    describe 'with a datastream' do
      let(:options) {
        {
          datastream: datastream,
          multiple: true,
        }
      }
      describe 'and minimal options' do
        it 'yields name and options' do
          @yielded = false
          subject.with_delegation_options {|name,opts|
            @yielded = true
            expect(name).to eq(field_name)
            expect(opts).to eq(to: datastream, unique: false)
          }
          expect(@yielded).to eq(true)
        end
      end
      describe 'with :at options' do
        let(:at_value) {[:ab]}
        let(:options) {
          {
            multiple: true,
            datastream: {to: datastream, at: at_value, unique: true }
          }
        }
        it 'yields name and options' do
          @yielded = false
          subject.with_delegation_options {|name,opts|
            @yielded = true
            expect(name).to eq(field_name)
            expect(opts).to eq(to: datastream, unique: !options.fetch(:multiple), at: at_value)
          }
          expect(@yielded).to eq(true)
        end
      end
    end
    describe 'without datastream' do
      let(:datastream) { nil }
      it 'does not yield name and options for #delegation' do
        @yielded = false
        subject.with_delegation_options {|name,opts|
          @yielded = true
        }
        expect(@yielded).to eq(false)
      end
    end
  end

  describe '#with_validation_options' do
    describe 'with validation options' do
      it 'yields name and options for #validations' do
        @yielded = false
        subject.with_validation_options do |name, opts|
          expect(name).to eq(field_name)
          expect(opts).to eq(validation_options)
          @yielded = true
        end
        expect(@yielded).to eq(true)
      end
    end
    describe 'without validation options' do
      let(:validation_options) { nil }
      it 'does not yield validation options' do
        @yielded = false
        subject.with_validation_options do |name, opts|
          @yielded = true
        end
        expect(@yielded).to eq(false)
      end
    end
  end

  describe '#with_accession_options' do
    describe 'with a datastream' do
      it 'does not yield name nor options' do
        @yielded = false
        subject.with_accession_options {|name,opts|
          @yielded = true
        }
        expect(@yielded).to eq(false)
      end
    end

    describe 'without datastream' do
      let(:datastream) { nil }
      it 'yields name and options for #accession' do
        @yielded = false
        subject.with_accession_options {|name,opts|
          @yielded = true
          expect(name).to eq(field_name)
          expect(opts).to eq({})
        }
        expect(@yielded).to eq(true)
      end
    end
  end

  describe '#options_for_input' do
    it 'is roughly what simple_form expects' do
      expect(subject.options_for_input(input_html: {size: 10})).to eq(
        {
          hint: 'Your title', as: 'multi_value', input_html:
          {
            style: 'title-picker', multiple: 'multiple', size: 10
          }
        }
      )
    end
  end

  describe '#default' do
    let(:instance) { Book.new }
    describe 'with string as default value' do
      let(:default_value) { '1234' }
      it 'defaults to the string' do
        expect(subject.default(instance)).to eq(default_value)
      end
    end

    describe 'with a lambda as the option' do
      let(:default_value) { lambda { object_id } }
      it "evaluates the lambda in the context of the default method's input" do
        expect(subject.default(instance)).to eq(instance.object_id)
      end
    end
  end

  describe '#wrap_writer_method(context)' do
    xit 'with a symbol referencing an instance method'
    xit 'with a lambda'
  end

  describe '#wrap_reader_method(context)' do
    xit 'with a symbol referencing an instance method'
    xit 'with a lambda'
  end
end
