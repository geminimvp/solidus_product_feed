module Spree
  class ProductFeed < ActiveRecord::Base
    belongs_to :store
    belongs_to :product_catalog

    validates :name, presence: true, uniqueness: true

    scope :default, -> { where(store: Spree::Store.default).
                         where.not(product_catalog_id: nil).first }
  end
end
