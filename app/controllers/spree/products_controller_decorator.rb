Spree::ProductsController.prepend(Module.new do
  class << self
    def prepended(klass)
      klass.respond_to :rss, :xml, only: :index
    end
  end

  def index
    load_feed_products if (request.format.rss? || request.format.xml?)

    respond_to do |format|
      format.rss { render inline: xml.generate, layout: false }
      format.xml { render inline: xml.generate, layout: false }
      format.html { super }
    end
  end

  private

  def load_feed_products
    @feed_products = Spree::Variant.where(id: item_ids)
  end

  def item_ids
    if product_catalog
      product_catalog.item_ids
    else
      all_variant_ids
    end
  end

  def all_variant_ids
    Spree::Variant.pluck(:id)
  end

  def product_catalog
    @product_catalog ||= product_feed.try(:product_catalog)
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
