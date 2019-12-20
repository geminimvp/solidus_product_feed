# frozen_string_literal: true

module Spree
  module Feeds
    class Base
      attr_reader :variants, :store

      def initialize(variants, store = Spree::Store.default)
        @variants = variants
        @store = store
        @products = {}
      end

      def generate
        raise NotImplementedError, "Please implement 'generate' in your feed: #{self.class}"
      end

      # This is used in all feed types to reduce the volume of SQL queries
      def variants_includes
        [
          :default_price,
          :option_values_variants,
          { option_values: :option_type },
        ]
      end

      def fetch_product(product_id)
        if @products[product_id].blank?
          @products[product_id] = Spree::Product.includes(:master, :brand_taxon, product_properties: :property).find_by(id: product_id)
        end
        @products[product_id]
      end
    end
  end
end
