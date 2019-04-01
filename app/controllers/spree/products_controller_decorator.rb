module Decorators
  module ProductsController
    extend ActiveSupport::Concern

    included do
      before_action :load_data, only: :index
      before_action(only: :index) do |controller|
        if controller.request.format.rss?
          feed_products
        end
      end

      respond_to :html, :rss

      def index
        respond_to do |format|
          format.rss { render inline: xml.generate, layout: false }
          format.html
        end
      end
    end

    private

    def load_data
      @searcher = build_searcher(params.merge(include_images: true))
      @products = @searcher.retrieve_products
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end

    def product_feed
      @product_feed ||= Spree::ProductFeed.
                        where('lower(name) = lower(?)', params[:feed]).first
    end

    def product_catalog
      @product_catalog ||= product_feed.try(:product_catalog)
    end

    def feed_products
      @feed_products ||= load_items
    end

    def load_items
      items = []

      Spree::Variant.where(id: product_catalog.item_ids).each do |variant|
        items << Spree::ProductFeedService.new(variant)
      end if product_catalog

      items
    end

    def csv
      @csv ||= Spree::Feeds::CSV.new(feed_products, current_store)
    end

    def xml
      @xml ||= Spree::Feeds::XML.new(feed_products, current_store)
    end
  end
end

Spree::ProductsController.include(Decorators::ProductsController)
