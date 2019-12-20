# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Spree::Admin::ProductFeedImagesController do
    stub_authorization!

    let!(:product) { create(:product) }
    let!(:product_feed) { create(:product_feed) }
    let!(:product_image) do
      product.master.images.create!(attachment: image('thinking-cat.jpg'))
    end

    describe '#create' do
      let(:create_params) {
        {
          product_feed_id: product_feed.id,
          product_feed_image: {
            image: {
              attachment: upload_image('thinking-cat.jpg'),
            },
          }
        }
      }

      it 'creates an image' do
        expect {
          post :create, params: create_params
        }.to change {
          Spree::Image.count
        }.by(1)
      end

      it 'creates an image as json' do
        expect {
          post :create, params: create_params, format: :json
        }.to change {
          Spree::Image.count
        }.by(1)
      end
    end

    describe '#destroy' do
      let(:request_params) {
        {
          product_feed_id: product_feed.id,
          id: product_image.id,
        }
      }

      before do
        # Ensure image exists first, so the count will change
        product_image
      end

      it 'destroys an image' do
        expect {
          delete :destroy, params: request_params
        }.to change {
          Spree::Image.count
        }.by(-1)
      end

      it 'destroys an image as json' do
        expect {
          delete :destroy, params: request_params, format: :json
        }.to change {
          Spree::Image.count
        }.by(-1)
      end
    end
  end
end
