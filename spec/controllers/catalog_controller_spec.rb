require 'spec_helper'

describe CatalogController do
  describe "#index" do
    it 'succeeds' do
      get :index
      expect(response).to be_success
    end
  end

  describe 'full-text indexing' do
    let(:user) { User.create(email: 'michael.giarlo@gmail.com', password: 'blahblah') }
    let(:generic_file) do
      GenericFile.new.tap do |f|
        f.apply_depositor_metadata(user.user_key)
        f.read_groups = ['public']
        f.save
      end
    end

    before do
      Sufia::GenericFile::Actor.new(generic_file, user).create_content(
        File.new("#{Rails.root}/spec/fixtures/document4.pdf"),
        "document4.pdf",
        'content')
    end

    after do
      user.destroy
      generic_file.destroy
    end

    it 'finds a file by full-text content' do
      get :index, q: 'cutepdf'
      expect(response).to be_success
      expect(response).to render_template('catalog/index')
      expect(assigns(:document_list).count).to eq(1)
    end
  end
end
