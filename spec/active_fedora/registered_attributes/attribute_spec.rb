require 'spec_helper'
require "active_fedora/registered_attributes/attribute"

describe ActiveFedora::RegisteredAttributes::Attribute do
  class Something < ActiveFedora::Base
  end
  let(:context) { Something }
  let(:field_name) { :title }
  let(:datastream) { 'SourApple' }
  let(:validation_options) {{ presence: true }}
  let(:options) {
    {
      datastream: datastream, hint: 'Your title',
      form: { input_html: {style: 'title-picker'}},
      multiple: true,
      displayable: true,
      editable: true,
      validates: validation_options
    }
  }
  subject { ActiveFedora::RegisteredAttributes::Attribute.new(context, field_name, options) }

  its (:displayable?) { should be_true }
  its (:editable?) { should be_true }

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

  it 'has #options_for_input' do
    expect(subject.options_for_input(input_html: {size: 10})).to eq(
      {
        hint: 'Your title', as: 'multi_value', input_html:
        {
          style: 'title-picker', multiple: 'multiple', size: 10
        }
      }
    )
  end

  it 'yields name and options for #validations' do
    @yielded = false
    subject.with_validation_options do |name, opts|
      expect(name).to eq(field_name)
      expect(opts).to eq(validation_options)
      @yielded = true
    end
    expect(@yielded).to eq(true)
  end

  describe 'with datastream' do

    it 'yields name and options for #delegation' do
      @yielded = false
      subject.with_delegation_options {|name,opts|
        @yielded = true
        expect(name).to eq(field_name)
        expect(opts).to eq(subject.send(:options_for_delegation))
      }
      expect(@yielded).to eq(true)
    end

    it 'does not yield name nor options for #accession' do
      @yielded = false
      subject.with_accession_options {|name,opts|
        @yielded = true
      }
      expect(@yielded).to eq(false)
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

    it 'yields name nor options for #accession' do
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
