require "graphql/batch"

module GraphQL
  module Extras
    class AssociationLoader < GraphQL::Batch::Loader
      def initialize(preload)
        @preload = preload
      end

      def cache_key(record)
        record.object_id
      end

      def perform(records)
        preloader = ActiveRecord::Associations::Preloader.new
        preloader.preload(records, @preload)

        records.each do |record|
          fulfill(record, nil) unless fulfilled?(record)
        end
      end
    end
  end
end
