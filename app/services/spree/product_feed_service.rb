# frozen_string_literal: true

module Spree
  class ProductFeedService
    include Rails.application.routes.url_helpers

    attr_reader :variant, :store

    def initialize(variant, store = Spree::Store.default, product = nil)
      @variant = variant
      @store = store
      @product = product
    end

    def product
      @product ||= variant.product
    end

    def master
      @master ||= product.master
    end

    def id
      variant.sku
    end

    delegate :slug, to: :product

    def title
      product.name
    end

    delegate :description, to: :product

    def url
      base_url = "#{store.url}/products/#{product.slug}"

      if base_url&.start_with?('http')
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
      product.brand_taxon&.name.to_s
    end

    def material
      property_value_by_name('Material').to_s.downcase
    end

    def google_product_category
      property_value_by_name('Google Product Category').to_s
    end

    def mpn
      mpn = property_value_by_name('MPN').to_s.downcase
      mpn.presence || variant.sku
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
      if image_link_base&.start_with?('http')
        image_link_base
      elsif image_link_base.present?
        "https://#{store.url}#{image_link_base}"
      end
    end

    def image_link_base
      if variant.first_image
        item_product_feed_image_link(variant.first_image)
      else
        item_product_feed_image_link(master.first_image)
      end
    end

    def item_product_feed_image_link(image)
      image&.attachment&.url(:large)
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
