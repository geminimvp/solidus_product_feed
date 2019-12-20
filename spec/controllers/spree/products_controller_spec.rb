# frozen_string_literal: true

require 'spec_helper'

describe Spree::ProductsController do
  let!(:store) { create(:store) }
  let!(:product) { create(:product, name: '2 Hams', price: 20.00) }
  let!(:variant) { create(:variant, product: product) }

  describe 'GET #index' do
    before do
      request.headers['Accept'] = 'application/rss+xml'
      get :index, params: { format: 'rss' }
    end

    context 'when no product feed exists' do
      it 'returns HTTP success' do
        expect(response).to have_http_status :ok
      end

      it 'returns the correct content type' do
        expect(response.content_type.split(';').first).to eq 'application/rss+xml'
      end

      it 'includes the correct products' do
        expect(response.body).to include(variant.sku)
      end
    end

    context 'when a product feed exists' do
      let(:product_catalog) do
        create(:product_catalog, item_ids: [variant.id.to_s], store: store)
      end
      let(:product_feed) do
        create(:product_feed,
          name: 'Test',
          product_catalog: product_catalog,
          store: store)
      end

      before do
        product_feed
        request.headers['Accept'] = 'application/rss+xml'
        get :index, params: { format: 'rss' }
      end

      it 'returns the http correct code' do
        expect(response).to have_http_status :ok
      end

      it 'returns the correct content type' do
        expect(response.content_type.split(';').first).to eq 'application/rss+xml'
      end
    end

    context 'when request type is XML' do
      before do
        request.headers['Accept'] = 'application/rss+xml'
        get :index, params: { format: 'xml' }
      end

      it 'returns the correct http code' do
        expect(response).to have_http_status :ok
      end

      it 'returns the correct content type' do
        expect(response.content_type.split(';').first).to eq 'application/xml'
      end
    end

    context 'when request type is anything' do
      before do
        request.headers['Accept'] = '*/*'

        get :index, params: {}
      end

      it 'returns the correct http code' do
        expect(response).to have_http_status :ok
      end

      it 'returns the correct content type' do
        expect(response.content_type.split(';').first).to eq 'text/html'
      end
    end

    context 'when request type is html' do
      before do
        get :index
      end

      it 'is successful' do
        expect(response).to be_successful
      end

      it 'makes products available' do
        expect(assigns(:products)).to be_present
      end
    end
  end
end
