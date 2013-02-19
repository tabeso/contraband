class FacebookImporter::Status < Contraband::Importer
  attributes :message, :author, priority: 2
end