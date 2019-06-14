module Spree
  module Feeds
    class Base
      attr_reader :variants, :store

      def initialize(variants, store = Spree::Store.default)
        @variants = variants
        @store = store
      end

      def generate
        raise NotImplementedError, "Please implement 'generate' in your feed: #{self.class}"
      end

      # This is used in all feed types to reduce the volume of SQL queries
      def variants_includes_base
        [
          :images,
          {
            product: [
              { product_properties: :property },
              { master: master_variant_includes },
              { taxons: :taxonomy },
            ],
          },
          { option_values: :option_type },
          :default_price,
        ]
      end

      def master_variant_includes
        [:images].tap do |mv_includes|
          if Spree::Variant.respond_to?(:variant_image_images)
            mv_includes << :variant_image_images
          end
        end
      end

      def variants_includes
        if Spree::Variant.respond_to?(:variant_image_images)
          base = variants_includes_base
          base << :variant_image_images
        else
          variants_includes_base
        end
      end
    end
  end
end
