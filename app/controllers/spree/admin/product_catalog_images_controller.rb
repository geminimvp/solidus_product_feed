# frozen_string_literal: true

module Spree
  module Admin
    class ProductCatalogImagesController < ResourceController
      def update
        begin
          @image = build_image
          @variant.images << @image unless @variant.images.include?(@image)

          if @variant.save
            flash[:success] = t('spree.admin.product_feed_image.success_uploaded')
          else
            flash[:error] = t('spree.admin.product_feed_image.error_uploaded')
          end
        rescue StandardError
          flash[:error] = t('spree.admin.product_feed_image.error_uploaded')
        end

        redirect_to edit_admin_product_catalog_path(@product_catalog)
      end

      private

      def load_resource
        @product_catalog = Spree::ProductCatalog.find(params[:product_catalog_id])
        @variant = Spree::Variant.find(params[:variant_id])
        @image = Spree::Image.find(params[:id])
      end

      def location_after_save
        edit_admin_product_catalog_path(@object)
      end

      def permitted_resource_params
        params.require(:product_catalog_image).permit(image: [:alt, :attachment])
      end

      def collection_url
        edit_admin_product_catalog_url(@product_catalog)
      end

      def build_image
        if @variant.product_feed_image.present?
          @variant.product_feed_image.update(permitted_resource_params[:image])
          @variant.product_feed_image
        else
          @variant.images.new(permitted_resource_params[:image].merge(viewable: @product_catalog))
        end
      end

      def model_class
        Spree::Image
      end
    end
  end
end
