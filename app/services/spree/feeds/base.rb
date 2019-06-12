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
      def variants_includes
        [
          :images,
          {
            product: [
              { product_properties: :property },
              { master: [:images, :variant_image_images] },
              { taxons: :taxonomy },
            ],
          },
          { option_values: :option_type },
          :variant_image_images,
          :default_price,
        ]

      end
    end
  end
end
