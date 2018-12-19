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
  let(:store) { create(:store, default: true) }

  context '.selected?' do
    it 'should return true if variant was selected' do
      expect(product_catalog.selected?(variant1.id)).to be_truthy
    end

    it "should return false if variant wasn't selected" do
      product_catalog.item_ids = []
      expect(product_catalog.selected?(variant2.id)).to be_falsey
    end
  end

  context '.all_selected?' do
    it 'should return true if all variants were selected' do
      expect(product_catalog.all_selected?([variant1])).to be_truthy
    end

    it "should return false if variants weren't selected" do
      product_catalog.item_ids = []
      expect(product_catalog.all_selected?([variant2])).to be_falsey
    end
  end
end
