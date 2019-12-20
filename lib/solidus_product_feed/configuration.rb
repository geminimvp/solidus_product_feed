# frozen_string_literal: true

module SolidusProductFeed
  class Configuration < Spree::Preferences::Configuration
    preference :formats, :hash, default: {
      mini: '48x48>',
      small: '100x100>',
      product: '240x240>',
      large: '600x600>'
    }

    preference :colors, :array, default: [
      %w(White white),
      %w(Black black),
      %w(Green green),
      %w(Blue blue),
      %w(Yellow yellow),
      %w(Red red)
    ]
  end
end
