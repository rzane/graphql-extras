require "graphql/extras/association_loader"

module GraphQL
  module Extras
    module Preload
      # @override
      def initialize(*args, preload: nil, **opts, &block)
        @preload = preload
        super(*args, **opts, &block)
      end

      # @override
      def resolve(object, args, ctx)
        return super unless @preload

        loader = AssociationLoader.for(@preload)
        loader.load(object.object).then do
          super(object, args, ctx)
        end
      end
    end
  end
end
