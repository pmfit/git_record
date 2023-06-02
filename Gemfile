source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in git_records.gemspec.
gemspec

gem "sqlite3"

gem "sprockets-rails"

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"

gem "octokit", "~> 6.1"

gem "httpparty", "~> 0.2.0"

gem 'dotenv-rails', groups: [:development, :test]
gem "pry", "~> 0.14.2"

group :test do
  gem 'rspec',    '~> 3.4'
  gem 'rspec-rails'
  gem 'simplecov', require: false
  gem 'cucumber', '~> 2.3'
  gem 'webmock'
end

