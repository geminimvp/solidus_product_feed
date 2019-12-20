# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::ProductFeedsController do
  let(:store) { create(:store, default: true) }
  let(:product) do
    create(:product, name: '2 Hams 20 Dollars', description: 'As seen on TV!')
  end
  let(:variant) { create(:variant, product: product) }
  let(:product_catalog) { create(:product_catalog) }

  stub_authorization!

  describe 'GET #index' do
    it 'redirects to the edit page' do
      get :index

      expect(response).to redirect_to(new_admin_product_feed_path)
    end
  end

  describe 'POST #create' do
    let(:params) do
      {
        product_feed: {
          name: 'Test',
          product_catalog_id: product_catalog.id,
          store_id: store.id
        }
      }
    end

    it 'creates the product feed' do
      expect {
        post :create, params: params
      }.to change {
        Spree::ProductFeed.count
      }.by(1)
    end

    it 'redirects to the edit page' do
      post :create, params: params
      expect(response).to redirect_to(edit_admin_product_feed_path(assigns(:product_feed).id))
    end
  end
end
