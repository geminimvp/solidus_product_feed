require 'spec_helper'

describe Spree::ProductsController do
  let!(:store) { create(:store) }
  let!(:product) { create(:product, name: '2 Hams', price: 20.00) }
  let!(:variant) { create(:variant, product: product) }

  before do
    # This attribute is added by the `solidus_asset_variant_options`
    # extension which isn't an explicit dependency of this gem.
    allow_any_instance_of(Spree::Variant).to receive(:variant_image_images).and_return([])
  end

  describe 'GET #index' do
    subject { get :index, params: { format: 'rss' } }

    context 'when no product feed exists' do
      it 'returns HTTP success' do
        is_expected.to have_http_status :ok
      end

      it 'returns the correct content type' do
        subject
        expect(response.content_type).to eq 'application/rss+xml'
      end

      it 'includes the correct products' do
        subject
        expect(response.body).to include(variant.sku)
      end
    end

    context 'when a product feed exists' do
      let!(:product_catalog) do
        create(:product_catalog, item_ids: [variant.id.to_s], store: store)
      end
      let!(:product_feed) do
        create(:product_feed,
               name: 'Test',
               product_catalog: product_catalog,
               store: store)
      end

      it 'returns the http correct code' do
        is_expected.to have_http_status :ok
      end

      it 'returns the correct content type' do
        subject
        expect(response.content_type).to eq 'application/rss+xml'
      end

      context 'as XML' do
        subject { get :index, params: { format: 'xml' } }

        it 'returns the correct http code' do
          is_expected.to have_http_status :ok
        end

        it 'returns the correct content type' do
          subject
          expect(response.content_type).to eq 'application/xml'
        end
      end

    end

    context 'as html' do
      it 'is successful' do
        get :index
        expect(response).to be_successful
      end

      it 'makes products available' do
        get :index
        expect(assigns(:products)).to be_present
      end
    end
  end
end
