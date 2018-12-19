require 'spec_helper'

describe Spree::ProductsController do
  let!(:store) { create(:store) }
  let(:product) { create(:product, name: '2 Hams', price: 20.00) }
  let(:variant) { create(:variant, product: product) }
  let!(:product_catalog) do
    create(:product_catalog, item_ids: [variant.id.to_s], store: store)
  end
  let!(:product_feed) do
    create(:product_feed,
           name: 'Test',
           feed_type: 'google_feed',
           product_catalog: product_catalog,
           store: store)
  end

  context 'GET #index' do
    subject { get :index, params: { format: 'rss' } }

    it 'returns the http correct code' do
      is_expected.to have_http_status :ok
    end

    it 'returns the correct content type' do
      subject
      expect(response.content_type).to eq 'application/rss+xml'
    end
  end
end
