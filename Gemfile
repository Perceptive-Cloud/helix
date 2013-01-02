source 'https://rubygems.org'

gemspec

gem 'rake'
gem 'json',        '>= 1.5.4'
gem 'rest-client', '1.6.7'
gem 'nori',        '1.1.3'
gem 'active_support'
gem 'i18n'

# If we use Travis we'll want these ignored.
group :development do
  gem 'yard'
  gem 'guard-rspec'
end

# Will be used with Travis.
group :test do
  gem 'rspec'
  gem 'simplecov'
end