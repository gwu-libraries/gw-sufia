require 'spec_helper'

describe CatalogController do
  describe "#index" do
    it 'should succeed' do
      get :index
      expect(response).to be_success
    end
  end
end
