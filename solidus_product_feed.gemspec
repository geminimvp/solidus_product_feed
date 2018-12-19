# encoding: UTF-8
$:.push File.expand_path('../lib', __FILE__)
require 'solidus_product_feed/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_product_feed'
  s.version     = SolidusProductFeed::VERSION
  s.summary     = 'Solidus extension that provides an RSS feed for products'
  s.description = 'A Solidus extension that provides an RSS feed for products'
  s.required_ruby_version = '>= 1.8.7'

  s.author      = 'Joshua Nussbaum'
  s.email       = 'joshnuss@gmail.com'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path  = 'lib'
  s.requirements  = 'none'

  solidus_version = ['>= 2.0', '< 3']
  s.add_dependency 'solidus', solidus_version
  s.add_dependency 'solidus_support'
  s.add_dependency 'deface'

  s.add_development_dependency 'capybara', '~> 2.18'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop', '0.43.0'
  s.add_development_dependency 'rubocop-rspec', '1.4.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'ffaker'
end
