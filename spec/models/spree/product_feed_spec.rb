# frozen_string_literal: true

require 'spec_helper'

describe Spree::ProductFeed, type: :model do
  let!(:store) { create(:store, default: true) }
  let!(:product_feed) { create(:product_feed, store: store) }

  describe '.default' do
    it 'ensures there is only one default' do
      expect(described_class.default).to eql(product_feed)
    end
  end
end
