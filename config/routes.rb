# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :product_feeds do
      resources :images, only: [:create, :destroy], controller: :product_feed_images
    end

    resources :product_catalogs do
      collection do
        get 'search'
      end

      member do
        get 'list'
      end

      resources :variants, only: [] do
        resources :images, only: [:edit, :update], controller: :product_catalog_images
      end
    end
  end
end
