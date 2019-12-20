# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Spree::Admin::ProductCatalogImagesController do
    stub_authorization!

    let!(:variant) { create(:variant) }
    let!(:product_catalog) { create(:product_catalog) }
    let!(:variant_image) do
      variant.images.create!(attachment: image('thinking-cat.jpg'))
    end
    let(:success_message) do
      I18n.t('spree.admin.product_feed_image.success_uploaded')
    end
    let(:error_message) do
      I18n.t('spree.admin.product_feed_image.error_uploaded')
    end

    describe '#update' do
      it 'updates an image' do
        post :update, params: {
          product_catalog_id: product_catalog.id,
          variant_id: variant.id,
          id: variant_image.id,
          product_catalog_image: {
            image: {
              attachment: upload_image('thinking-cat.jpg')
            }
          }
        }

        aggregate_failures do
          expect(response).to be_redirect
          expect(flash[:success]).to eq(success_message)
        end
      end

      it 'returns an error' do
        post :update, params: {
          product_catalog_id: product_catalog.id,
          variant_id: variant.id,
          id: variant_image.id,
          product_catalog_image: {
            image: {
              attachment: image('thinking-cat.jpg')
            }
          }
        }

        aggregate_failures do
          expect(response).to be_redirect
          expect(flash[:error]).to eq(error_message)
        end
      end
    end
  end
end
