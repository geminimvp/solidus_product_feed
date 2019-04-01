module Spree
  module Admin
    class ProductFeedsController < ResourceController
      before_action :load_data, only: [:edit, :new, :create]

      def collection
        params[:q] ||= {}
        params[:q][:s] ||= 'name asc'
        @search = super.ransack(params[:q])
        @product_feeds = @search.result.
                         page(params[:page]).
                         per(params[:per_page])
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
