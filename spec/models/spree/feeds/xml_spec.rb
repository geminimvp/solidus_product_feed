require 'spec_helper'

module Spree
  module Feeds
    RSpec.describe XML, type: :model do
      let(:generator) { described_class.new(feed_products, store) }
      let(:store) {
        create(:store, url: 'www.mysite.com', name: 'Extra Cool Store')
      }
      let(:feed_products) { Spree::Variant.available }
      let!(:variant) { create(:variant) }

      describe '#doc_header' do
        subject { generator.doc_header }

        it 'contains the site name' do
          expect(subject).to include('<title>Extra Cool Store</title>')
        end

        it 'contains the site URL' do
          expect(subject).to include('<link>www.mysite.com</link>')
        end

        it 'does not contain the split marker' do
          expect(subject).to_not include('item_content')
        end

      end
    end
  end
end
