require "graphql/batch"

module GraphQL
  module Extras
    module Batch
      class AssociationLoader < GraphQL::Batch::Loader
        def initialize(name)
          @name = name
        end

        def cache_key(record)
          record.object_id
        end

        def perform(records)
          preloader = ActiveRecord::Associations::Preloader.new
          preloader.preload(records, @name)

          records.each do |record|
            fulfill(record, record.public_send(@name))
          end
        end
      end

      module Resolvers
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def association(name)
            lambda do |record, _args, _ctx|
              loader = AssociationLoader.for(name)
              loader.load(record)
            end
          end
        end

        def association(record, name)
          loader = AssociationLoader.for(name)
          loader.load(record)
        end
      end
    end
  end
end
