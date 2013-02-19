class Concert
  include Mongoid::Document
  include Mongoid::Timestamps
  include Contraband::Importable

  field :name,        type: String
  field :description, type: String

  belongs_to :artist
end