require 'spec_helper'

RSpec.describe Client, type: :model do
  context "When creating" do
    let!(:valid_user) { build(:client) }

    it { should validate_presence_of(:name) }
  end
end