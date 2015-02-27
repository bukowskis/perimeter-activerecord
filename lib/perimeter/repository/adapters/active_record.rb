require 'operation'
require 'perimeter/repository'
require 'perimeter/repository/adapters/abstract'
require 'active_support/concern'

module Perimeter
  module Repository
    module Adapters
      module ActiveRecord
        extend ActiveSupport::Concern

        include Perimeter::Repository
        include Perimeter::Repository::Adapters::Abstract

        module ClassMethods

          def find(id)
            record = backend.find id
            entity = record_to_entity record
            Operations.success :record_found, object: entity

          rescue ::ActiveRecord::RecordNotFound => exception
            Operations.failure :record_not_found, object: exception

          rescue => exception
            ::Trouble.notify exception
            Operations.failure :backend_error, object: exception
          end

          def create(attributes)
            record = attributes_to_record attributes

            if record.invalid?
              return Operations.failure(:validation_failed, object: record_to_entity(record))
            end

            id = record.id.presence || attributes[:id].presence || attributes['id'].presence
            if id && backend.find_by_id(id)
              return Operations.failure :record_already_exists
            end

            if record.save
              Operations.success :record_created, object: record_to_entity(record)
            else
              Operations.failure :creation_failed, object: record_to_entity(record)
            end

          rescue => exception
            ::Trouble.notify exception
            Operations.failure :backend_error, object: exception
          end

          # ––––––––
          # Updating
          # ––––––––

          def update(id, attributes)
            unless record = backend.find_by_id(id)
              return Operations.failure :record_not_found
            end

            record.send :assign_attributes, attributes

            if record.invalid?
              entity = record_to_entity record
              return Operations.failure(:validation_failed, object: entity)
            end

            if record.save
              Operations.success :record_updated, object: record_to_entity(record)
            else
              Operations.failure :update_failed
            end

          rescue => exception
            ::Trouble.notify exception
            Operations.failure :backend_error, object: exception
          end

          def destroy(id)
            unless record = backend.find_by_id(id)
              return Operations.success(:nothing_to_destroy)
            end

            if record.destroy
              Operations.success :record_destroyed, object: record_to_entity(record)
            else
              Operations.failure :destruction_failed
            end

          rescue => exception
            ::Trouble.notify exception
            Operations.failure :backend_error, object: exception
          end

        end

      end
    end
  end
end
