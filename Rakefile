# frozen_string_literal: true

require 'bundler'
Bundler::GemHelper.install_tasks

begin
  require 'spree/testing_support/extension_rake'
  require 'rubocop/rake_task'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  RuboCop::RakeTask.new

  task default: %i(first_run rubocop spec)
rescue LoadError # rubocop:disable Lint/HandleExceptions
  # no rspec available
end

task :first_run do # rubocop:disable Rails/RakeEnvironment
  if Dir['spec/dummy'].empty?
    Rake::Task[:test_app].invoke
    Dir.chdir("../../")
  end
  Rake::Task[:spec].invoke
end

desc 'Generates a dummy app for testing'
task :test_app do # rubocop:disable Rails/RakeEnvironment
  ENV['LIB_NAME'] = 'solidus_product_feed'
  Rake::Task['extension:test_app'].invoke
end
