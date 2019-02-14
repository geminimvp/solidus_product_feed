module Spree
  class ProductFeedService
    include Rails.application.routes.url_helpers

    attr_reader :product, :variant, :store

    def initialize(variant)
      @variant = variant
      @product = variant.product
      @store = Spree::Store.default
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
      "#{Spree::Store.default.url}/#{product.slug}"
    end

    def color
      option_type = Spree::OptionType.find_by(presentation: 'Color')
      variant.option_values.find_by(option_type_id: option_type.try(:id)).
        try(:presentation).to_s
    end

    def gender
      property = Spree::Property.find_by(name: 'Gender')
      product.product_properties.find_by(property_id: property.try(:id)).
        try(:value).to_s.downcase
    end

    def size
      property = Spree::Property.find_by(name: 'Size')
      product.product_properties.find_by(property_id: property.try(:id)).
        try(:value).to_s
    end

    def brand
      property = Spree::Property.find_by(name: 'Brand')
      product.product_properties.find_by(property_id: property.try(:id)).
        try(:value) || store.name
    end

    def material
      property = Spree::Property.find_by(name: 'Material')
      product.product_properties.find_by(property_id: property.try(:id)).
        try(:value).to_s.downcase
    end

    def google_product_category
      property = Spree::Property.find_by(name: 'Google Product Category')
      product.product_properties.find_by(property_id: property.try(:id)).
        try(:value).to_s
    end

    def mpn
      property = Spree::Property.find_by(name: 'MPN')
      product.product_properties.find_by(property_id: property.try(:id)).
        try(:value).to_s.downcase
    end

    def product_type
      property = Spree::Property.find_by(name: 'Type')
      product.product_properties.find_by(property_id: property.try(:id)).try(:value)
    end

    # Must be "new", "refurbished", or "used".
    def condition
      'new'
    end

    def item_group_id
      product.slug
    end

    def price
      Spree::Money.new(product.try(:price))
    end

    def availability
      total_on_hand = product.try(:total_on_hand)

      if total_on_hand == Float::INFINITY || total_on_hand.to_i > 0
        'in stock'
      else
        'out of stock'
      end
    end

    def image_link
      return "#{store.url}#{variant.try(:images).first.try(:attachment).try(:url, :product_feed)}" if variant.images.any?
      return "#{store.url}#{product.try(:images).first.try(:attachment).try(:url, :product_feed)}" if product.images.any?
    end
  end
end
