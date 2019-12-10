# frozen_string_literal: true

module Spree
  module TaxonsControllerDecorator
  end
end

Spree::TaxonsController.prepend(
  Module.new do
    class << self
      def prepended(klass)
        klass.include ActionController::Live
      end
    end

    def show
      super

      if request.format.rss? || request.format.xml?
        @feed_products = Spree::Variant.includes(:product).merge(@products)
      end

      respond_to do |format|
        format.all {}
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

    def xml
      @xml ||= Spree::Feeds::Xml.new(@feed_products, current_store)
    end
  end
)
