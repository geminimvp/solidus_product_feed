module Spree
  module Feeds
    class Base
      attr_reader :items, :store

      def initialize(items, store = Spree::Store.default)
        @items = items
        @store = store
      end

      def generate
        raise NotImplementedError, "Please implement 'generate' in your feed: #{self.class}"
      end
    end
  end
end
