require 'chefspec'
require 'rspec-expectations'

at_exit { ChefSpec::Coverage.report! }
