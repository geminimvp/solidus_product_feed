module Spree
  class ProductFeed < Spree::Base
    belongs_to :store
    belongs_to :product_catalog

    validates :name, presence: true, uniqueness: true

    def self.default
      where(store: Spree::Store.default).where.not(item_ids: []).first
    end
  end
end
