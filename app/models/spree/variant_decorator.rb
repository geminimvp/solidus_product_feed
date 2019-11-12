Spree::Variant.class_eval do
  def self.available
    includes(:product).references(:product).where("spree_products.available_on <= ?", Time.zone.now)
  end

  def product_feed_image
    images.where(viewable_type: 'Spree::ProductCatalog').first
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
end
