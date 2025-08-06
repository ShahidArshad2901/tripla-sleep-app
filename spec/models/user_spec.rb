require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:sleep_records).dependent(:destroy) }
    it { should have_many(:active_follows).class_name('Follow').dependent(:destroy) }
    it { should have_many(:passive_follows).class_name('Follow').dependent(:destroy) }
    it { should have_many(:following).through(:active_follows) }
    it { should have_many(:followers).through(:passive_follows) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end
  end

  describe 'following relationships' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'can follow another user' do
      create(:follow, follower: user, following: other_user)
      expect(user.following).to include(other_user)
    end

    it 'can have followers' do
      create(:follow, follower: other_user, following: user)
      expect(user.followers).to include(other_user)
    end
  end
end
