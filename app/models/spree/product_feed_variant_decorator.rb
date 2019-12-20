# frozen_string_literal: true

module Spree
  module ProductFeedVariantDecorator
    module ClassMethods
      def available
        includes(:product).references(:product).where("spree_products.available_on <= ?", Time.zone.now)
      end
    end

    def self.prepended(klass)
      klass.extend ClassMethods
    end

    def product_feed_image
      images.find_by(viewable_type: 'Spree::ProductCatalog')
    end

    def display_option_text
      options_text.present? && options_text || 'Master Variant'
    end

    def first_image
      if respond_to?(:gallery)
        gallery.images.first
      else
        display_image
      end
    end
    ::Spree::Variant.prepend self
  end
end
