# frozen_string_literal: true

require 'spec_helper'

describe Spree::ProductFeedService do
  let(:store_url) { 'example.com' }
  let!(:store) { create(:store, default: true, url: store_url) }
  let!(:gender) do
    create(:property, name: 'Gender', presentation: 'Gender')
  end
  let!(:material) do
    create(:property, name: 'Material', presentation: 'Material')
  end
  let!(:google_product_category) do
    create(:property, name: 'Google Product Category', presentation: 'Google Product Category')
  end
  let!(:mpn) { create(:property, name: 'MPN') }
  let!(:type) { create(:property, name: 'Type') }
  let!(:color_option_type) {
    create(:option_type, name: 'tshirt-color', presentation: 'Color')
  }
  let!(:color_option_value) {
    create(:option_value, name: 'Blue', presentation: 'Blue', option_type: color_option_type)
  }
  let!(:size_option_type) {
    create(:option_type, name: 'tshirt-size', presentation: 'Size')
  }
  let!(:size_option_value) {
    create(:option_value, name: 'Large', presentation: 'L', option_type: size_option_type)
  }

  let(:product) do
    create(:product,
      name: '2 Hams 20 Dollars',
      description: 'As seen on TV!',
      option_types: [size_option_type, color_option_type])
  end

  let!(:product_image) do
    product.master.images.create!(attachment_file_name: 'hams.png')
  end

  let(:variant) do
    create(:variant,
      product: product,
      option_values: [size_option_value, color_option_value])
  end

  let(:variant_image) do
    variant.images.create!(attachment_file_name: 'hams.png')
  end

  let(:service) { described_class.new(variant) }

  describe '#id' do
    subject { service.id }

    it { is_expected.to eq(variant.sku) }
  end

  describe '#description' do
    subject { service.description }

    it { is_expected.to eq(product.description) }
  end

  describe '#title' do
    subject { service.title }

    it { is_expected.to eq(product.name) }
  end

  describe '#slug' do
    subject { service.slug }

    it { is_expected.to eq(product.slug) }
  end

  describe '#url' do
    subject { service.url }

    it { is_expected.to eq("https://#{store.url}/products/#{product.slug}") }

    context 'when store URL already includes protocol' do
      let(:store_url) { 'https://example.com' }

      it { is_expected.to eq("#{store.url}/products/#{product.slug}") }
    end
  end

  describe '#condition' do
    subject { service.condition }

    it { is_expected.to eq('new') }
  end

  describe '#price' do
    subject { service.price }

    it { is_expected.to eq(Spree::Money.new(19.99, currency: 'USD')) }
  end

  describe '#availability' do
    subject { service.availability }

    context 'when item is out of stock' do
      it { is_expected.to eq('out of stock') }
    end

    context 'when item is in stock' do
      before do
        variant.stock_items.first.adjust_count_on_hand(1)
      end

      it { is_expected.to eq('in stock') }
    end

    context 'when inventory is not tracked' do
      before do
        variant.update(track_inventory: false)
      end

      it { is_expected.to eq('in stock') }
    end
  end

  describe '#image_link' do
    subject { service.image_link }

    let(:expected_image_path) {
      'https://example.com/system/spree/images/attachments/\d*/\d*/\d*/large/hams.png'
    }
    let(:image_path_regex) {
      /\A#{expected_image_path}\Z/
    }

    context 'when the variant has images' do
      it { is_expected.to match(image_path_regex) }
    end

    context 'when the product has images' do
      before do
        allow(variant).to receive(:images).and_return([])
        allow(product.master).to receive(:images) { [product_image] }
      end

      it { is_expected.to match(image_path_regex) }
    end

    context "when the product and variant don't have images" do
      before do
        allow(variant).to receive(:images).and_return([])
        allow(variant).to receive(:display_image).and_return(nil)
        allow(product.master).to receive(:images).and_return([])
        allow(product.master).to receive(:display_image).and_return(nil)
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#gender' do
    subject { service.gender }

    let!(:gender_product_property) {
      create(:product_property, product: product, property: gender, value: 'Unisex')
    }

    it { is_expected.to eq(gender_product_property.value.downcase) }
  end

  describe '#size' do
    subject { service.size }

    it { is_expected.to eq('L') }
  end

  describe '#brand' do
    subject { service.brand }

    context 'when product has a brand' do
      let(:brand_taxonomy) { create(:taxonomy, name: 'Brand') }
      let(:taxonomy_root) {
        brand_taxonomy.root
      }
      let(:brand_taxon) {
        taxon = create(:taxon, name: 'EngineCommerce')
        taxon.move_to_child_of(taxonomy_root)
        taxon
      }

      before do
        product.taxons << brand_taxon
      end

      it { is_expected.to eq('EngineCommerce') }
    end

    context 'when product has a taxon with no taxonomy' do
      # rubocop:disable Rails/SkipsModelValidations
      let(:orphan_root) {
        oroot = create(:taxon, name: 'Warbucks')
        oroot.update_columns(taxonomy_id: nil)
        oroot
      }
      let(:orphan_taxon) {
        taxon = create(:taxon, name: 'Annie')
        taxon.update_columns(taxonomy_id: nil)
        taxon.move_to_child_of(orphan_root)
        taxon
      }
      # rubocop:enable Rails/SkipsModelValidations

      before do
        product.taxons << orphan_taxon
      end

      it { is_expected.to eq('') }
    end
  end

  describe '#material' do
    subject { service.material }

    let!(:material_product_property) {
      create(:product_property, product: product, property: material, value: 'Cotton')
    }

    it { is_expected.to eq(material_product_property.value.downcase) }
  end

  describe '#google_product_category' do
    subject { service.google_product_category }

    let!(:category_product_property) {
      create(:product_property, product: product, property: google_product_category, value: 'Apparel & Accessories > Clothing')
    }

    it { is_expected.to eq(category_product_property.value) }
  end

  describe '#mpn' do
    subject { service.mpn }

    context 'when mpn is present' do
      let!(:mpn_product_property) {
        create(:product_property, product: product, property: mpn, value: '1')
      }

      it { is_expected.to eq(mpn_product_property.value) }
    end

    context 'when mpn is missing' do
      it { is_expected.to eq(variant.sku) }
    end
  end

  describe '#product_type' do
    subject { service.product_type }

    let!(:type_product_property) {
      create(:product_property, product: product, property: type, value: 'Apparel & Accessories > Clothing')
    }

    it { is_expected.to eq(type_product_property.value) }
  end

  describe '#color' do
    subject { service.color }

    it { is_expected.to eq('Blue') }
  end
end
