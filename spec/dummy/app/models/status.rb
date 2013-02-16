require 'active_attr'

class Status
  include ActiveAttr::Model
  include Contraband::Importable

  attribute :id
  attribute :message
  attribute :author

  def self.find_or_initialize_by_source_id_and_service(id, service)
    new(id: id)
  end
end