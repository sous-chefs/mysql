require 'spec_helper'

describe 'server recipe' do  
  it 'puts the lotion in the basket' do
    expect(port 3306).to be_listening
  end
end
