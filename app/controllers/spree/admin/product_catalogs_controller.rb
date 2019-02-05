module Spree
  module Admin
    class ProductCatalogsController < ResourceController
      before_action :load_data, except: [:index]
      before_action :load_variants, only: [:edit]

      include Spree::Admin::ProductCatalogsHelper

      private

      def collection
        params[:q] ||= {}
        params[:q][:s] ||= 'name asc'
        @search = super.ransack(params[:q])
        @product_catalogs = @search.result.
                            page(params[:page]).
                            per(params[:per_page])
      end

      def load_data
        @product_catalogs = Spree::ProductCatalog.where(store: current_store).order(:name)
      end

      def load_variants
        @variants = Spree::Config.variant_search_class.new(params[:variant_search_term], scope: variant_scope).results
        @variants = @variants.includes(:images, stock_items: :stock_location, product: :variant_images)
        @variants = @variants.includes(option_values: :option_type)
        @variants = @variants.page(params[:page]).per(params[:per_page] || Spree::Config[:admin_variants_per_page])
      end

      def location_after_save
        if params[:page].present?
          edit_admin_product_catalog_path(@object, page: params[:page])
        else
          edit_admin_product_catalog_path(@object)
        end
      end

      def permitted_resource_params
        if params[:product_catalog][:item_ids]
          params[:product_catalog][:item_ids] = JSON.parse(params[:product_catalog][:item_ids])
        end

        super
      end

      def variant_scope
        Spree::Variant.accessible_by(current_ability, :read)
      end

      def model_class
        Spree::ProductCatalog
      end
    end
  end
end
