# frozen_string_literal: true

module Spree
  module Admin
    class ProductFeedsController < ResourceController
      before_action :load_data, only: [:index, :edit, :new, :create]

      def index
        if model_class.default.present?
          redirect_to edit_admin_product_feed_path(@product_feeds.first)
        else
          redirect_to new_admin_product_feed_path
        end
      end

      def new
        if model_class.default.present?
          redirect_to edit_admin_product_feed_path(model_class.default)
        else
          render :new
        end
      end

      def create
        super
      end

      def edit
        super
      end

      private

      def load_data
        @product_catalogs = Spree::ProductCatalog.by_store(current_store).order(:name)
        @product_feed_image = Spree::ProductFeedImage.new
      end

      def location_after_save
        edit_admin_product_feed_path(@object)
      end

      def model_class
        Spree::ProductFeed
      end
    end
  end
end
