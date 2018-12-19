Spree::Variant.class_eval do
  def display_option_text
    options_text.present? && options_text || 'Master Variant'
  end
end
