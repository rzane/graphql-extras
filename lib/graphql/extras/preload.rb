module GraphQL
  module Extras
    class PreloadSource < GraphQL::Dataloader::Source
      def initialize(preload)
        @preload = preload
      end

      def fetch(records)
        preloader = ActiveRecord::Associations::Preloader.new
        preloader.preload(records, @preload)
        records
      end
    end

    module Preload
      # @override
      def initialize(*args, preload: nil, **opts, &block)
        @preload = preload
        super(*args, **opts, &block)
      end

      # @override
      def resolve(object, args, context)
        if @preload
          loader = context.dataloader.with(PreloadSource, @preload)
          loader.load(object.object)
        end

        super
      end
    end

    module PreloadDefault
      # @override
      def initialize(*args, preload: nil, **opts, &block)
        @preload = preload
        if maybe_preload(opts[:type])
          @preload_by_name = opts[:name]&.to_s
        end
        super(*args, **opts, &block)
      end

      # @override
      def resolve(object, args, context)
        if @preload == false
          # nop
        elsif @preload
          loader = context.dataloader.with(PreloadSource, @preload)
          loader.load(object.object)
        elsif @preload_by_name && object.object.class.respond_to?(:reflections) && object.object.class.reflections.key?(@preload_by_name)
          loader = context.dataloader.with(PreloadSource, @preload_by_name)
          loader.load(object.object)
        end

        super
      end

      private

      def maybe_preload(type)
        (
          type.is_a?(Array) &&
          type.first.is_a?(Class) &&
          type.first < GraphQL::Schema::Object
        ) || (
          type.is_a?(Class) &&
          type < GraphQL::Schema::Object
        )
      end
    end
  end
end
