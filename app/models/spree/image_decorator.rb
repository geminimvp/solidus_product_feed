Spree::Image.class_eval do
  has_attached_file :attachment,
                    styles: proc { |attachment| attachment.instance.styles },
                    default_style: :product,
                    default_url: 'noimage/:style.png',
                    convert_options: { mini: '-strip -auto-orient -colorspace sRGB',
                                       small: '-strip -auto-orient -colorspace sRGB',
                                       product: '-strip -auto-orient -colorspace sRGB',
                                       large: '-strip -auto-orient -colorspace sRGB' },
                    only_process: [:original, :mini, :small, :product, :large, :product_feed, :thumbnail]

  def styles
    feed_styles = {}
    feed_styles[:thumbnail]    = { geometry: '100x100',
                                   base_path: Rails.root.join('app/assets/images/default_product/product.png'),
                                   processors: [:overlay] } if Rails.root.join('app/assets/images/default_product/product.png').exist?
    feed_styles[:product_feed] = { geometry: '500x500',
                                   image_id: product_feed.try(:id),
                                   processors: [:overlay] } if product_feed
    feed_styles[:affine_clamp] = { geometry: '500x500',
                                   image_id: product_feed.try(:id),
                                   processors: [:affine_clamp] } if product_feed.try(:affine_clamp?)
    feed_styles[:color_fill]   = { geometry: '500x500',
                                   color: product_feed.try(:color) || 'white',
                                   image_id: product_feed.try(:id),
                                   processors: [:color_fill] } if product_feed.try(:color_fill?)
    SolidusProductFeed::Config.formats.merge(feed_styles)
  end

  def options
    return {} if new_record?

    {}.tap do |image|
      image['id'] = id
      image['name'] = attachment_file_name
      image['alt'] = alt
      image['urls'] = {
        'mini' => attachment.url(:mini),
        'small' => attachment.url(:small),
        'product' => attachment.url(:product),
        'product_feed' => attachment.url(:product_feed),
        'large' => attachment.url(:large)
      }
    end
  end

  private

  def product_feed
    Spree::ProductFeed.try(:default)
  end
end
