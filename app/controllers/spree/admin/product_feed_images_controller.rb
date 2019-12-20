# frozen_string_literal: true

module Spree
  module Admin
    class ProductFeedImagesController < ResourceController
      before_action :load_data

      respond_to :html, :json

      def create
        @image = @product_feed.images.new(permitted_resource_params[:image])

        if @image.save
          respond_to do |format|
            format.json { render json: @product_feed.images_options, status: :ok }
            format.html { redirect_to edit_admin_product_feed_path(@product_feed) }
          end
        else
          respond_to do |format|
            format.json { render json: @image.errors.full_messages.join(', '), status: :bad_request }
            format.html { redirect_to edit_admin_product_feed_path(@product_feed) }
          end
        end
      end

      def destroy
        @image = Spree::Image.find(params[:id])

        if @image.destroy
          respond_to do |format|
            format.json { render json: @product_feed.images_options, status: :ok }
            format.html { redirect_to edit_admin_product_feed_path(@product_feed) }
          end
        else
          respond_to do |format|
            format.json { render json: @image.errors.full_messages.join(', '), status: :bad_request }
            format.html { redirect_to edit_admin_product_feed_path(@product_feed) }
          end
        end
      end

      private

      def load_data
        @product_feed = Spree::ProductFeed.find(params[:product_feed_id])
      end

      def permitted_resource_params
        params.require(:product_feed_image).permit(image: [:alt, :attachment])
      end

      def collection_url
        edit_admin_product_feed_url(@product_feed)
      end

      def model_class
        Spree::Image
      end
    end
  end
end
