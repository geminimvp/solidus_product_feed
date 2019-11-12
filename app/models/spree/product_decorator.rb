module Spree
  module ProductFeedProductDecorator
    def self.prepended(base)
      base.has_one :brand_classification, -> { includes(taxon: :taxonomy).references(:taxonomy).where(spree_taxonomies: { name: 'Brand' }) }, class_name: 'Spree::Classification'
      base.has_one :brand_taxon, -> { includes(:taxonomy).references(:taxonomy) }, through: :brand_classification, source: :taxon
    end

    Spree::Product.prepend self
  end
end
