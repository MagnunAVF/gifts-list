require "spec_helper"

RSpec.describe Category, type: :model do
  context "When creating" do
    context "a simple category WITHOUT subcategories" do
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:client_id) }

      it { should belong_to(:client) }
    end

    context "a parent category WITH subcategories" do
      let!(:parent_category) { create(:category, :with_subcategories) }

      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:client_id) }

      it { should belong_to(:client) }

      it "should have subcategories" do
        expect(parent_category.subcategories.count).to be > 0
      end

      it "subcategories MUST refer to parent category" do
        parent_category.subcategories.each do |subcategory|
          expect(subcategory.parent_category.id).to be parent_category.id
        end
      end
    end
  end
end
