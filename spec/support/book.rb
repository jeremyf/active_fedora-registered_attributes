class Book < ActiveFedora::Base
  has_metadata name: "properties", type: ActiveFedora::SimpleDatastream do |m|
    m.field('title')
  end
end