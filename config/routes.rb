Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :product_feeds
    resources :product_catalogs do
      collection do
        get 'search'
      end
    end
  end
end
