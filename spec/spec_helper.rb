require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.color = true
  config.log_level = :error
end

at_exit { ChefSpec::Coverage.report! }
