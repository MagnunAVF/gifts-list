require "spec_helper"

RSpec.describe Client, type: :model do
  context "When creating" do
    it { should validate_presence_of(:name) }

    it { should have_many(:products) }
    it { should have_many(:categories) }
    it { should have_many(:lists) }
  end
end
