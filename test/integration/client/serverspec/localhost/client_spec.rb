require 'spec_helper'

describe command('mysql --version') do
  it { should return_exit_status 0 }
end
