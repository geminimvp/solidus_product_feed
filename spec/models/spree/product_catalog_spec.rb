# frozen_string_literal: true

require 'spec_helper'

describe Spree::ProductCatalog do
  let!(:store) { create(:store, default: true) }
  let!(:variant1) { create(:variant) }
  let!(:variant2) { create(:variant) }
  let(:product_catalog) do
    create(:product_catalog,
      name: 'Test',
      item_ids: [variant1.id.to_s],
      store: store)
  end

  describe '.selected?' do
    it 'returns true if variant was selected' do
      expect(product_catalog).to be_selected(variant1.id)
    end

    it "returns false if variant wasn't selected" do
      product_catalog.item_ids = []
      expect(product_catalog).not_to be_selected(variant2.id)
    end
  end

  describe '.all_selected?' do
    it 'returns true if all variants were selected' do
      expect(product_catalog).to be_all_selected([variant1])
    end

    it "returns false if variants weren't selected" do
      product_catalog.item_ids = []
      expect(product_catalog).not_to be_all_selected([variant2])
    end
  end
end
