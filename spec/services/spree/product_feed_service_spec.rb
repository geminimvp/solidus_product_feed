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

  let!(:product_properties) do
    create(:product_property, product: product, property: gender, value: 'Unisex')
    create(:product_property, product: product, property: material, value: 'Cotton')
    create(:product_property, product: product, property: google_product_category, value: 'Apparel & Accessories > Clothing')
    create(:product_property, product: product, property: mpn, value: '1')
    create(:product_property, product: product, property: type, value: 'Apparel & Accessories > Clothing')
  end

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

  let!(:variant_image) do
    variant.images.create!(attachment_file_name: 'hams.png')
  end

  let(:service) { described_class.new(variant) }

  describe '#id' do
    subject { service.id }

    it "delegates to the product's SKU" do
      expect(subject).to eq(variant.sku)
    end
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

    it { is_expected.to eq("https://#{store.url}/#{product.slug}") }
    context 'when store URL already includes protocol' do
      let(:store_url) { 'https://example.com' }
      it { is_expected.to eq("#{store.url}/#{product.slug}") }
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

    context 'returns out of stock' do
      it { is_expected.to eq('out of stock') }
    end

    context 'returns in stock' do
      before do
        variant.stock_items.first.adjust_count_on_hand(1)
      end

      it { is_expected.to eq('in stock') }
    end

    context 'when inventory is not tracked' do
      before do
        variant.update_attributes(track_inventory: false)
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
      %r|\A#{expected_image_path}\Z|
    }

    context 'when the variant has images' do
      it { is_expected.to match(image_path_regex) }
    end

    context 'when the product has images' do
      before do
        allow_any_instance_of(Spree::Variant).to receive(:images).and_return([])
        allow_any_instance_of(Spree::Product).to receive(:images).and_return([product_image])
      end

      it { is_expected.to match(image_path_regex) }
    end

    context "when the product an variant don't have images" do
      before do
        allow_any_instance_of(Spree::Product).to receive(:images).and_return([])
        allow_any_instance_of(Spree::Variant).to receive(:images).and_return([])
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#gender' do
    subject { service.gender }

    it { is_expected.to eq('unisex') }
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
      let(:orphan_root) {
        create(:taxon, name: 'Warbucks', taxonomy_id: nil)
      }
      let(:orphan_taxon) {
        taxon = create(:taxon, name: 'Annie', taxonomy_id: nil)
        taxon.move_to_child_of(orphan_root)
        taxon
      }

      before do
        product.taxons << orphan_taxon
      end

      it {
        is_expected.to eq('')
      }
    end

  end

  describe '#material' do
    subject { service.material }

    it { is_expected.to eq('cotton') }
  end

  describe '#google_product_category' do
    subject { service.google_product_category }

    it { is_expected.to eq('Apparel & Accessories > Clothing') }
  end

  describe '#mpn' do
    subject { service.mpn }

    it { is_expected.to eq('1') }
  end

  describe '#product_type' do
    subject { service.product_type }

    it { is_expected.to eq('Apparel & Accessories > Clothing') }
  end

  describe '#color' do
    subject { service.color }

    it { is_expected.to eq('Blue') }
  end
end
