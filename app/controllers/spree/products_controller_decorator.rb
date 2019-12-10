# frozen_string_literal: true

module Spree
  module ProductsControllerDecorator
  end
end

Spree::ProductsController.prepend(Module.new do
  class << self
    def prepended(klass)
      klass.include ActionController::Live
      klass.respond_to :html, :rss, :xml, only: :index
      klass.before_action :default_format_html
    end
  end

  def index
    load_feed_products if request.format.rss? || request.format.xml?

    respond_to do |format|
      format.all { super }
      format.rss { render_xml_feed(response) }
      format.xml { render_xml_feed(response) }
    end
  end

  private

  def render_xml_feed(response)
    response.stream.write xml.doc_header
    xml.write_elements(response.stream)
    response.stream.write xml.doc_footer
  ensure
    response.stream.close
  end

  def load_feed_products
    @feed_products = if product_catalog
                       Spree::Variant.where(id: item_ids)
                     else
                       Spree::Variant.available
                     end
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
    @xml ||= Spree::Feeds::Xml.new(@feed_products, current_store)
  end

  # Force `*/*` requests to be interpreted as HTML
  def default_format_html
    return if params[:format].present?

    request.format = "html"
  end
end)
