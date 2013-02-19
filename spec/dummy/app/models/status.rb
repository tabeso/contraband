class Status
  include Mongoid::Document
  include Contraband::Importable

  field :message, type: String
  field :author,  type: String
end