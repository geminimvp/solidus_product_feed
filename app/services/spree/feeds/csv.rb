require 'csv'
require 'builder'

module Spree
  module Feeds
    class CSV < Spree::Feeds::Base
      def generate
        ::CSV.generate do |csv|
          csv << header_node

          items.each do |item|
            csv << item_node(item)
          end
        end
      end

      private

      def header_node
        %w(
          id
          title
          description
          availability
          condition
          price
          link
          image_link
          brand
          additional_image_link
          age_group
          color
          gender
          item_group_id
          google_product_category
          material
          pattern
          product_type
          sale_price
          sale_price_effective_date
          shipping
          shipping_weight
          size
        )
      end

      def item_node(item)
        [
          item.id, # id
          item.title, # title
          item.description, # description
          item.availability, # availability
          'new', # condition
          item.price.money.format(symbol: false, with_currency: true), # price
          item.url, # link
          item.image_link, # image_link
          item.brand, # brand
          nil, # additional_image_link
          nil, # age_group
          item.color,
          item.gender, # gender
          nil, # item_group_id
          item.google_product_category, # google_product_category
          item.material, # material
          nil, # pattern
          item.product_type, # product_type
          nil, # sale_price
          nil, # sale_price_effective_date
          nil, # shipping
          nil, # shipping_weight
          item.size # size
        ]
      end
    end
  end
end
