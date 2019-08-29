require 'simplecov'
SimpleCov.start

ENV["TEST"] = "1"
ENV["JETS_ENV"] ||= "test"
# Ensures aws api never called. Fixture home folder does not contain ~/.aws/credentails
ENV['HOME'] = "spec/fixtures/home"

require 'faker'
require "byebug"
require "fileutils"
require "jets"

abort("The Jets environment is running in production mode!") if Jets.env == "production"
Jets.boot

require "jets/spec_helpers"

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec

    with.library :active_record
    with.library :active_model
  end
end

module Helpers
  def payload(name)
    JSON.load(IO.read("spec/fixtures/payloads/#{name}.json"))
  end
end

RSpec.configure do |config|
  config.include Helpers

  config.include FactoryBot::Syntax::Methods
  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
