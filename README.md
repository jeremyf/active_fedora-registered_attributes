# ActiveFedora::RegisteredAttributes

[![Build Status](https://travis-ci.org/jeremyf/active_fedora-registered_attributes.png?branch=master)](https://travis-ci.org/jeremyf/active_fedora-registered_attributes)

An ActiveFedora extension for consolidating the attribute definitions for an object.

By registering an attribute, we can introspect on the model for:

* generating forms
* generating default views
* generating reasonably helpful API documentation/explanation
* helping developers readily see what the data attributes are

## Installation

Add this line to your application's Gemfile:

    gem 'active_fedora-registered_attributes'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_fedora-registered_attributes

## Usage

    class Foo < ActiveFedora::Base
      include ActiveFedora::RegisteredAttributes

      has_metadata name: "descMetadata", type: FooMetadataDatastream

      attribute :title,
        datastream: :descMetadata, multiple: false,
        label: "Title of your Senior Thesis",
        validates: { presence: { message: 'Your must have a title.' } }

      attribute :creator,
        datastream: :descMetadata, multiple: true,
        label: "Author",
        hint: "Enter your preferred name",
        writer: :parse_person_names,
        reader: :parse_person_names,
        validates: { presence: { message: "You must have an author."} }
    end

See [ActiveFedora::RegisteredAttributes::Attribute](lib/active_fedora/registered_attributes/attribute.rb)

## Internationalization

If you utilize internationalization, such as below, then regardless of what
your model indicates as the label, it will use the internationalization.

    en:
      activemodel:
        attributes:
          foo:
            internationalized_field: Welcome

## TODO

* Add internationalization support for hints and validation messages.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
