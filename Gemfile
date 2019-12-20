# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem 'solidus', github: 'solidusio/solidus', branch: branch

# Provides basic authentication functionality for testing parts of your engine
gem 'solidus_auth_devise'

gem 'factory_bot', '> 4.10.0'

# Needed to help Bundler figure out how to resolve dependencies
# otherwise it takes forever to resolve them
rails_version_spec = if branch == 'master' || Gem::Version.new(branch[1..-1]) >= Gem::Version.new('2.10.0')
                       '~> 6.0'
                     else
                       '~> 5.0'
                     end
gem 'rails', rails_version_spec

case ENV['DB']
when 'mysql'
  gem 'mysql2'
when 'postgresql'
  gem 'pg'
else
  gem 'sqlite3'
end

group :test do
  gem 'rails-controller-testing'
end

gem 'solidus_dev_support', github: 'solidusio-contrib/solidus_dev_support'

gemspec
