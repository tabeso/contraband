class Artist
  include Mongoid::Document
  include Mongoid::Timestamps
  include Contraband::Importable

  field :name, type: String
  field :bio,  type: String

  has_many :albums
end