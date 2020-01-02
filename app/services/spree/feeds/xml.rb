# frozen_string_literal: true

require 'i18n'
require 'ox'

module Spree
  module Feeds
    class Xml < Spree::Feeds::Base

      def doc_header
        doc_parts.first
      end

      def doc_footer
        doc_parts.last
      end

      def doc_parts
        doc_skeleton.split('<item_content/>')
      end

      # The XML document with no items, we then split this into
      # header and footer
      def doc_skeleton
        @doc_skeleton ||= Ox::Builder.new(indent: 2) { |b|
          b.instruct(:xml, version: '1.0', encoding: 'UTF-8')
          b.element('rss', version: '2.0', 'xmlns:g' => 'http://base.google.com/ns/1.0') do
            b.element('channel') do
              b.element('title') { b.text store.name }
              b.element('link') { b.text store.url }
              b.element('description') { b.text "Find out about new products on http://#{store.url} first!" }
              b.element('item_content')
            end
          end
        }
      end

      # Write item elements to an IO, which can be a streaming response
      def write_elements(io)
        variants.includes(variants_includes).references(:spree_taxonomies).find_each(batch_size: 100) do |variant|
          product = fetch_product(variant.product_id)
          fs_item = Spree::ProductFeedService.new(variant, store, product)

          item_element = Ox::Builder.new(indent: 2) { |b|
            b.element('item') do
              b.element('g:id') { b.text fs_item.id }
              b.element('g:title') { b.text fs_item.title }
              b.element('g:description') { b.text(fs_item.description, true) }
              b.element('g:link') { b.text fs_item.url }
              b.element('g:image_link') { b.text fs_item.image_link }
              b.element('g:brand') { b.text fs_item.brand }
              b.element('g:condition') { b.text fs_item.condition }
              b.element('g:availability') { b.text fs_item.availability }
              b.element('g:price') { b.text fs_item.price.money.format(symbol: false, with_currency: true) }
              b.element('g:mpn') { b.text fs_item.mpn }
              b.element('g:item_group_id') { b.text fs_item.item_group_id }
              b.element('g:google_product_category') { b.text fs_item.google_product_category }
              b.element('g:custom_label_0') { b.text "Color: #{fs_item.color}" }
              b.element('g:custom_label_1') { b.text "Gender: #{fs_item.gender}" }
              b.element('g:custom_label_2') { b.text "Material: #{fs_item.material}" }
              b.element('g:custom_label_3') { b.text "Product Type: #{fs_item.product_type}" }
              b.element('g:custom_label_4') { b.text "Size: #{fs_item.size}" }
            end
          }
          io.write item_element
        end
      end

      def generate
        xml = Ox::Builder.new(indent: 2) { |b|
          b.instruct(:xml, version: '1.0', encoding: 'UTF-8')
          b.element('rss', version: '2.0', 'xmlns:g' => 'http://base.google.com/ns/1.0') do
            b.element('channel') do
              b.element('title') { b.text store.name }
              b.element('link') { b.text store.url }
              b.element('description') { b.text "Find out about new products on http://#{store.url} first!" }
              variants.includes(variants_includes).references(:spree_taxonomies).find_each(batch_size: 100) do |variant|
                product = fetch_product(variant.product_id)
                fs_item = Spree::ProductFeedService.new(variant, store, product)
                b.element('item') do
                  b.element('g:id') { b.text fs_item.id }
                  b.element('g:title') { b.text fs_item.title }
                  b.element('g:description') { b.text(fs_item.description, true) }
                  b.element('g:link') { b.text fs_item.url }
                  b.element('g:image_link') { b.text fs_item.image_link }
                  b.element('g:brand') { b.text fs_item.brand }
                  b.element('g:condition') { b.text fs_item.condition }
                  b.element('g:availability') { b.text fs_item.availability }
                  b.element('g:price') { b.text fs_item.price.money.format(symbol: false, with_currency: true) }
                  b.element('g:mpn') { b.text fs_item.mpn }
                  b.element('g:item_group_id') { b.text fs_item.item_group_id }
                  b.element('g:google_product_category') { b.text fs_item.google_product_category }
                  b.element('g:custom_label_0') { b.text "Color: #{fs_item.color}" }
                  b.element('g:custom_label_1') { b.text "Gender: #{fs_item.gender}" }
                  b.element('g:custom_label_2') { b.text "Material: #{fs_item.material}" }
                  b.element('g:custom_label_3') { b.text "Product Type: #{fs_item.product_type}" }
                  b.element('g:custom_label_4') { b.text "Size: #{fs_item.size}" }
                end
              end
            end
          end
        }

        xml
      end
    end
  end
end
