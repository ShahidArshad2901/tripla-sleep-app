require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe 'associations' do
    it { should belong_to(:follower).class_name('User') }
    it { should belong_to(:following).class_name('User') }
  end

  describe 'validations' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    describe 'uniqueness' do
      before { create(:follow, follower: user1, following: user2) }

      it 'prevents duplicate follows' do
        duplicate_follow = build(:follow, follower: user1, following: user2)
        expect(duplicate_follow).not_to be_valid
        expect(duplicate_follow.errors[:follower_id]).to include('has already been taken')
      end
    end

    describe 'self-following' do
      it 'prevents users from following themselves' do
        self_follow = build(:follow, follower: user1, following: user1)
        expect(self_follow).not_to be_valid
        expect(self_follow.errors[:following_id]).to include("can't follow yourself")
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      user1 = create(:user)
      user2 = create(:user)
      follow = build(:follow, follower: user1, following: user2)
      expect(follow).to be_valid
    end
  end
end
