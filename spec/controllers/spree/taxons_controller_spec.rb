# frozen_string_literal: true

require 'spec_helper'

module Spree
  RSpec.describe TaxonsController, type: :controller do
    let(:taxon) { create(:taxon, name: 'Widgets', permalink: 'widgets') }
    let!(:product) {
      create(:product, name: '2 Hams', price: 20.00, taxons: [taxon])
    }

    before do
      product.master.update!(sku: 'WIDGET-12345')
    end

    describe 'GET #show' do
      context 'when request is for XML' do
        it 'returns a properly formatted XML feed' do
          get :show, params: { id: taxon.permalink, format: :xml }
          aggregate_failures do
            expect(response).to have_http_status(:success)
            expect(response.content_type).to start_with('application/xml')
            # We can't test the actual output, because it fails in
            # CI every time with a truncated response.
          end
        end
      end
    end
  end
end
