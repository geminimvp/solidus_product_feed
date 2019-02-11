module Spree
  class ProductFeed < Spree::Base
    serialize :options, JSON
    belongs_to :store
    belongs_to :product_catalog

    has_many :images, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: 'Spree::Image'
    has_one :overlay_image, dependent: :destroy, class_name: 'Spree::Image', foreign_key: :overlay_image_id

    validates :name, presence: true, uniqueness: true

    def self.default
      where(store: Spree::Store.default).where.not(product_catalog_id: nil).first
    end

    def color
      options['color']
    end

    def color_fill
      options['color_fill']
    end

    def affine_clamp
      options['affine_clamp']
    end

    def color_fill?
      color_fill == 'true'
    end

    def affine_clamp?
      affine_clamp == 'true'
    end

    def images_options
      return [] if images.blank?

      [].tap do |payload|
        images.each do |image|
          payload.push(
            {}.tap do |o|
              o['id'] = image.id
              o['name'] = image.attachment_file_name
              o['alt'] = image.alt
              o['urls'] = {
                'mini' => image.attachment.url(:mini),
                'small' => image.attachment.url(:small),
                'product' => image.attachment.url(:product),
                'large' => image.attachment.url(:large),
                'thumbnail' => image.attachment.url(:thumbnail),
                'product_feed' => image.attachment.url(:product_feed)
              }
            end
          )
        end
      end
    end
  end
end
