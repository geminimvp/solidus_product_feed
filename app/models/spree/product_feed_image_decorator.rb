# frozen_string_literal: true

module Spree
  module ProductFeedImageDecorator
    def self.prepended(klass)
      klass.has_attached_file :attachment,
        styles: proc { |attachment| attachment.instance.styles },
        default_style: :product,
        default_url: 'noimage/:style.png',
        convert_options: { mini: '-strip -auto-orient -colorspace sRGB',
                           small: '-strip -auto-orient -colorspace sRGB',
                           product: '-strip -auto-orient -colorspace sRGB',
                           large: '-strip -auto-orient -colorspace sRGB' },
        only_process: [:original, :mini, :small, :product, :large, :product_feed, :thumbnail]
    end

    def styles
      feed_styles = {}
      if Rails.root.join('app/assets/images/default_product/product.png').exist?
        feed_styles[:thumbnail]    = { geometry: '100x100',
                                       base_path: Rails.root.join('app/assets/images/default_product/product.png'),
                                       processors: [:overlay] }
      end
      if product_feed
        feed_styles[:product_feed] = { geometry: '500x500',
                                       image_id: product_feed.try(:id),
                                       processors: [:overlay] }
      end
      if product_feed.try(:affine_clamp?)
        feed_styles[:affine_clamp] = { geometry: '500x500',
                                       image_id: product_feed.try(:id),
                                       processors: [:affine_clamp] }
      end
      if product_feed.try(:color_fill?)
        feed_styles[:color_fill]   = { geometry: '500x500',
                                       color: product_feed.try(:color) || 'white',
                                       image_id: product_feed.try(:id),
                                       processors: [:color_fill] }
      end
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

    ::Spree::Image.prepend self
  end
end
