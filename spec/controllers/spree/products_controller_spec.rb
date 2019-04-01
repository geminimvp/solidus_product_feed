require 'spec_helper'

describe Spree::ProductsController do
  let!(:store) { create(:store) }
  let!(:user) { create(:user) }
  let(:product) { create(:product, name: '2 Hams', price: 20.00) }
  let(:variant) { create(:variant, product: product) }
  let!(:product_catalog) do
    create(:product_catalog, item_ids: [variant.id.to_s], store: store)
  end
  let!(:product_feed) do
    create(:product_feed,
           name: 'Test',
           product_catalog: product_catalog,
           store: store)
  end

  before do
    allow(controller).to receive_messages(try_spree_current_user: user)
    expect_any_instance_of(Spree::Config.searcher_class).to receive(:current_user=).with(user)
  end

  context 'GET #index' do
    it 'returns html view' do
      get :index
      expect(response.status).to eq(200)
    end

    it 'returns the correct content type' do
      get :index
      expect(response.content_type).to eq 'text/html'
    end

    it 'returns xml view' do
      get :index, params: { format: 'rss' }
      expect(response.status).to eq(200)
    end

    it 'returns the correct content type' do
      get :index, params: { feed: 'test', format: 'rss' }
      expect(response.content_type).to eq 'application/rss+xml'
    end
  end
end
