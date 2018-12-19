Spree::ProductsController.class_eval do
  before_action(only: :index) do |controller|
    if controller.request.format.rss?
      load_feed_products
    end
  end

  def index
    respond_to do |format|
      if product_feed
        format.rss { render inline: xml.generate, layout: false }
      else
        format.rss { redirect_to action: 'index' }
      end

      format.html
    end
  end

  private

  def load_feed_products
    items = []
    product_catalog = product_feed.try(:product_catalog)

    Spree::Variant.where(id: product_catalog.item_ids).each do |variant|
      items << Spree::ProductFeedService.new(variant)
    end if product_catalog

    @feed_products = items
  end

  def product_feed
    @product_feed ||= Spree::ProductFeed.default
  end

  def csv
    @csv ||= Spree::Feeds::CSV.new(@feed_products, current_store)
  end

  def xml
    @xml ||= Spree::Feeds::XML.new(@feed_products, current_store)
  end
end
