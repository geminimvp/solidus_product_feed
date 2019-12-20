# frozen_string_literal: true

require 'spec_helper'

module Spree
  module Feeds
    RSpec.describe Xml, type: :model do
      let(:generator) { described_class.new(feed_products, store) }
      let(:store) {
        create(:store, url: 'www.mysite.com', name: 'Extra Cool Store')
      }
      let(:feed_products) { Spree::Variant.available }
      let(:variant) { create(:variant) }

      describe '#doc_header' do
        subject { generator.doc_header }

        it { is_expected.to include('<title>Extra Cool Store</title>') }

        it { is_expected.to include('<link>www.mysite.com</link>') }

        it { is_expected.not_to include('item_content') }
      end
    end
  end
end
