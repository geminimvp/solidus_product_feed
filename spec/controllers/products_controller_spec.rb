require 'spec_helper'

describe Spree::ProductsController, type: :controller do
  render_views

  context "GET #index" do
    describe "when request is .rss format" do
      subject { get :index, params: { format: 'rss' } }

      let!(:product) { create :product, name: "2 Hams", price: 20.00 }

      it { is_expected.to have_http_status :ok }

      it { is_expected.to render_template 'spree/products/index' }

      it 'returns the correct content type' do
        subject
        expect(response.content_type).to eq 'application/rss+xml'
      end
    end

    describe "when request is .xml format" do
      subject { get :index, params: { format: 'xml' } }

      let!(:product) { create :product, name: "2 Hams", price: 20.00 }

      it { is_expected.to have_http_status :ok }

      it { is_expected.to render_template 'spree/products/index' }

      it 'returns the correct content type' do
        subject
        expect(response.content_type).to eq 'application/xml'
      end
    end
  end
end
