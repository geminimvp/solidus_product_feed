# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'feed management', type: :request do
  stub_authorization!

  it 'allows a custotmer to edit a feed' do
    get '/admin/product_feeds/new'
    expect(response).to render_template(:new)
  end
end
