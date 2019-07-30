module Spree
  class ProductFeedService
    include Rails.application.routes.url_helpers

    attr_reader :product, :variant, :store

    def initialize(variant, store = Spree::Store.default)
      @variant = variant
      @product = variant.product
      @store = store
    end

    def id
      variant.sku
    end

    def slug
      product.try(:slug)
    end

    def title
      product.try(:name)
    end

    def description
      product.try(:description)
    end

    def url
      base_url = "#{store.url}/products/#{product.slug}"

      if base_url =~ /\Ahttp/
        base_url
      else
        "https://#{base_url}"
      end

    end

    def color
      option_value_by_type('Color')
    end

    def gender
      property_value_by_name('Gender').to_s.downcase
    end

    def size
      option_value_by_type('Size')
    end

    def brand
      taxon_name_by_taxonomy('Brand')
    end

    def material
      property_value_by_name('Material').to_s.downcase
    end

    def google_product_category
      property_value_by_name('Google Product Category').to_s
    end

    def mpn
      mpn = property_value_by_name('MPN').to_s.downcase
      if mpn.blank?
        variant.sku
      else
        mpn
      end
    end

    def product_type
      property_value_by_name('Type').to_s
    end

    # Must be "new", "refurbished", or "used".
    def condition
      'new'
    end

    def item_group_id
      product.slug
    end

    def price
      Spree::Money.new(variant.price)
    end

    def availability
      if variant.in_stock?
        'in stock'
      else
        'out of stock'
      end
    end

    def image_link
      if image_link_base =~ /\Ahttp/
        return image_link_base
      elsif image_link_base.present?
        return "https://#{store.url}#{image_link_base}"
      end
    end

    def image_link_base
      if variant.images.any?
        item_product_feed_image_link(variant)
      elsif product.images.any?
        item_product_feed_image_link(product)
      end
    end

    def item_product_feed_image_link(item)
      item_product_feed_image(item)&.attachment&.url(:large)
    end

    # Determine which image to use for this variant/product in the feed
    def item_product_feed_image(item)
      if item.images.present?
        item.images.order(:position).first
      elsif item&.product&.present?
        item.product.display_image
      end
    end

    private

    def option_value_by_type(option_type_presentation)
      variant.option_values.detect { |ov|
        ov.option_type.presentation == option_type_presentation
      }.try(:presentation).to_s
    end

    def taxon_name_by_taxonomy(taxonomy_name)
      product.taxons.detect { |taxon|
        taxon.taxonomy&.name == taxonomy_name
      }.try(:name).to_s
    end

    def property_value_by_name(property_name)
      product.product_properties.detect { |p_prop|
        p_prop.property.name == property_name
      }.try(:value)
    end
  end
end
