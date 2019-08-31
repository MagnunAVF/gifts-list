require "spec_helper"

RSpec.describe Product, type: :model do
  context "When creating" do
    it { should validate_presence_of(:name) }

    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than(0) }

    it { should validate_presence_of(:client_id) }
    it { should belong_to(:client) }
  end
end
