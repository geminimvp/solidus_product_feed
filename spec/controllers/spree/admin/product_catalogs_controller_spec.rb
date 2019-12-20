# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::ProductCatalogsController do
  let(:store) { create(:store, default: true) }
  let(:product) do
    create(:product, name: '2 Hams 20 Dollars', description: 'As seen on TV!')
  end
  let(:variant) { create(:variant, product: product) }

  stub_authorization!

  describe 'GET #index' do
    it 'returns 200 status' do
      get :index

      expect(response).to be_ok
    end
  end

  describe 'POST #create' do
    let(:params) do
      {
        product_catalog: {
          name: 'Test',
          item_ids: [variant.id].to_s,
          store_id: store.id
        }
      }
    end

    before do
      post :create, params: params
    end

    it 'creates the product catalog' do
      expect(assigns(:product_catalog)).not_to be_nil
    end

    it 'redirects to the edit page' do
      expect(response).to redirect_to(edit_admin_product_catalog_path(assigns(:product_catalog)))
    end
  end
end
