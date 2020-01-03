require 'spec_helper'

module Spree
  RSpec.describe TaxonsController do
    let(:taxon) { create(:taxon, name: 'Widgets', permalink: 'widgets') }
    let!(:product) {
      create(:product, name: '2 Hams', price: 20.00, taxons: [taxon])
    }

    before do
      product.master.update_attributes!(sku: 'WIDGET-12345')
    end

    describe 'GET #show' do
      context 'when request is for XML' do
        render_views

        it 'returns a properly formatted XML feed' do
          get :show, params: { id: taxon.permalink, format: :xml }
          aggregate_failures do
            expect(response).to have_http_status(:success)
            expect(response.content_type).to eq('application/xml')
            expect(response.body).to include(product.master.sku)
          end
        end
      end
    end
  end
end
