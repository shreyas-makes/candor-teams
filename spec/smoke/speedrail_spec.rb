require 'rails_helper'

RSpec.describe 'Speedrail baseline' do
  it 'boots Rails 8 successfully' do
    expect(Rails::VERSION::MAJOR).to eq(8)
  end
end 