module Spree
  module Admin
    module ProductCatalogsHelper
      def set_product_feed_image(variant, product_catalog)
        return variant.images.first unless variant.product_feed_image

        variant.product_feed_image
      end

      def product_catalog_options(variant, product_catalog)
        attrs = JSON.parse(variant.to_json)

        attrs[:image] = (variant.product_feed_image || variant.images.first).options
        attrs[:slug] = variant.slug
        attrs[:name] = variant.name
        attrs[:is_master] = variant.display_option_text
        attrs[:is_selected] = product_catalog.selected?(variant.id)

        attrs
      end
    end
  end
end
