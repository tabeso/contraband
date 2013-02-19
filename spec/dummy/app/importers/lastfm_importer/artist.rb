class LastfmImporter::Artist < Contraband::Importer
  attributes :name, :bio
  has_many :albums
end