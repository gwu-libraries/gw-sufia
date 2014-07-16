require 'spec_helper'

describe 'generic_files/show.html.erb' do
  let(:generic_file) {
    content = double('content', versions: [], mimeType: 'application/pdf')
    stub_model(GenericFile, noid: '123',
               depositor: 'bob',
               audit_stat: 1,
               content: content)
  }

  before do
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    allow_any_instance_of(Ability).to receive(:can?).and_return(true)
    assign(:generic_file, generic_file)
    assign(:events, [])
  end

  describe 'analytics' do

    context 'when enabled' do
      before do
        Sufia.config.analytics = true
      end

      it 'appears on page' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).to have_selector('a#stats', count: 1)
      end
    end

    context 'when disabled' do
      before do
        Sufia.config.analytics = false
      end

      it 'does not appear on page' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).to have_no_selector('a#stats')
      end
    end
  end

  describe 'featured' do

    context "public file" do
      before do
        allow(generic_file).to receive(:public?).and_return(true)
      end

      it "shows featured feature link for public file" do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).to have_selector('a[data-behavior="feature"]', count: 1)
      end
    end

    context "non public file" do
      before do
        allow(generic_file).to receive(:public?).and_return(false)
      end

      it "does not show feature link for non public file" do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).to have_no_selector('a[data-behavior="feature"]', count: 1)
      end
    end
  end

  describe 'collections list' do

    context "when the file is not featured in any collections" do
      it "should display the empty message" do
        render
        expect(rendered).to have_text(t('sufia.file.collections_list.empty'))
      end
    end

    #TODO: Write test for "when the file is included in one more more collections"
    #  it "should list the titles of collections that this file is in" do
  end
end

