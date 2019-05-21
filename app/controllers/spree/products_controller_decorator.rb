Spree::ProductsController.prepend(Module.new do
  class << self
    def prepended(klass)
      klass.respond_to :rss, :xml, only: :index
    end
  end

  def index
    load_feed_products if request.format.rss? || request.format.xml?
    respond_to do |format|
      if product_feed
        format.rss { render inline: xml.generate, layout: false }
      else
        format.rss { redirect_to action: 'index' }
      end
      format.html { super }
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
end)
