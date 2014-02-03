require 'chefspec'
require 'chefspec/berkshelf'
require 'rspec-expectations'

at_exit { ChefSpec::Coverage.report! }
