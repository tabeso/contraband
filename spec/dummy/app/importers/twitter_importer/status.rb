class TwitterImporter::Status < Contraband::Importer
  attributes :message, :created_at, :updated_at
end
