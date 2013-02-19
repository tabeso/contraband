class TwitterImporter::Status < Contraband::Importer
  attributes :message, :author
end