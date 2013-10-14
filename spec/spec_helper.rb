ENV["RAILS_ENV"] = "test"

require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
  add_group 'Libraries', 'lib'
end

require 'support/downloads'
require 'support/upload_sig_opts'
require 'support/plays'
require 'support/uploads'

