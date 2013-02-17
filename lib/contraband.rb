require 'active_model'
require 'active_support/core_ext'

require 'contraband/version'
require 'contraband/errors'
require 'contraband/importable'
require 'contraband/importer'
require 'contraband/railtie' if defined?(Rails)

# Add English load path by default
I18n.load_path << File.join(File.dirname(__FILE__), 'config', 'locales', 'en.yml')

module Contraband
  extend self

  ##
  # @example
  #     Contraband.import(Band, :lastfm, resource)
  #
  # @param [Class] model
  #   The model to import.
  #
  # @param [Symbol] service
  #   The service of the resource.
  #
  # @param [Object] resource
  #   The resource to import.
  #
  def import(model, service, resource)
    model.importer_class(service).import(resource)
  end

  ##
  # @param [Class] model
  #   The model to import.
  #
  # @param [Symbol] service
  #   The service of the resource.
  #
  # @param [String] id
  #   The identifier of the resource.
  #
  # @param [Hash] data
  #   The resource data to be imported.
  #
  def import_async(model, service, id, data = {})
    defined?(DeferredImport) or raise Errors::DeferredImporterMissing
    DeferredImport.import(model.importer_class(service), id, data)
  end

  def logger
    @logger ||= (rails_logger || default_logger)
  end

  private

  def rails_logger
    defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
  end

  def default_logger
    require 'logger'
    logger = Logger.new($stdout)
    logger.level = Logger::INFO
    logger
  end
end # Contraband