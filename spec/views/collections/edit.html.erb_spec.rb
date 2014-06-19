require 'spec_helper'

describe 'collections/_form.html.erb' do
  describe 'when the collection edit form is rendered' do
    let(:collection) { Collection.new({title: 'the title', description: 'the description',
                                       creator: 'the creator'})}

    before do
      controller.request.path_parameters[:id] = 'j12345'
      assign(:collection, collection)
    end

    it "should draw the metadata fields for collection" do
      render
      expect(rendered).to have_selector("input#collection_title", count: 1)
      expect(rendered).to have_selector("input#collection_creator", count: 1)
      expect(rendered).to have_selector("textarea#collection_description", count: 1)
    end
  end
end
