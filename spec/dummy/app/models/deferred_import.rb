class DeferredImport
  include Mongoid::Document
  include Contraband::Mongoid::DeferredImport
end