require 'i18n'
require 'builder'

module Spree
  module Feeds
    class XML < Spree::Feeds::Base
      def generate
        xml.instruct! :xml, version: '1.0'

        xml.rss version: '2.0', 'xmlns:g' => 'http://base.google.com/ns/1.0' do
          xml.channel do
            xml.title store.name
            xml.link store.url
            xml.description "Find out about new products on http://#{store.url} first!"

            items.each do |item|
              xml.item do
                xml.tag! 'g:id', item.id
                xml.tag! 'g:title', item.title
                xml.tag! 'g:description', item.description
                xml.tag! 'g:link', item.url
                xml.tag! 'g:image_link', item.image_link
                xml.tag! 'g:brand', item.brand
                xml.tag! 'g:condition', item.condition
                xml.tag! 'g:availability', item.availability
                xml.tag! 'g:price', item.price.money.format(symbol: false, with_currency: true)
                xml.tag! 'g:mpn', item.mpn
                xml.tag! 'g:google_product_category', item.google_product_category
                xml.tag! 'g:custom_label_0', "Color: #{item.color}"
                xml.tag! 'g:custom_label_1', "Gender: #{item.gender}"
                xml.tag! 'g:custom_label_2', "Material: #{item.material}"
                xml.tag! 'g:custom_label_3', "Product Type: #{item.product_type}"
                xml.tag! 'g:custom_label_4', "Size: #{item.size}"
              end
            end
          end
        end
      end

      private

      def xml
        @xml ||= Builder::XmlMarkup.new(indent: 2)
      end
    end
  end
end
