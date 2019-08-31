require "spec_helper"

RSpec.describe List, type: :model do
  context "When creating" do
    it { should validate_presence_of(:name) }

    it { should belong_to(:client) }
  end
end
