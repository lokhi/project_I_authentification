require 'rspec'
require 'active_record'
$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require_relative '../database'

require 'bundler'

Bundler.setup :default, :development, :test

require 'rack/test'
require_relative '../sauth'
RSpec.configure do |config|
  config.include Rack::Test::Methods
end


