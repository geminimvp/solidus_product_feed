Spree::TaxonsController.prepend(
  Module.new do
    class << self
      def prepended(klass)
        klass.include ActionController::Live
        klass.respond_to :html, :rss, :xml, only: :show
        klass.before_action :default_format_html, only: :show
      end
    end

    def show
      super

      if (request.format.rss? || request.format.xml?)
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

      response.stream.close
    end

    def xml
      @xml ||= Spree::Feeds::XML.new(@feed_products, current_store)
    end

    # Force `*/*` requests to be interpreted as HTML
    def default_format_html
      if params[:format].blank?
        request.format = "html"
      end
    end
  end
)
