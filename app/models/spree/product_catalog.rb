module Spree
  class ProductCatalog < ActiveRecord::Base
    serialize :item_ids, Array

    belongs_to :store

    after_create :populate_default_items

    validates :name, presence: true, uniqueness: true

    def selected?(variant_id)
      item_ids.include?(variant_id.to_s)
    end

    def all_selected?(variants)
      variant_ids = variants.map(&:id).map(&:to_s)
      (variant_ids - item_ids).blank?
    end

    private

    def populate_default_items
      variants = Spree::Product.all.map(&:variants_including_master).flatten
      update_attribute(:item_ids, variants.map(&:id).map(&:to_s))
    end
  end
end
