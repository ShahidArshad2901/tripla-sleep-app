require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:started_at) }

    describe 'ended_at validation' do
      let(:sleep_record) { build(:sleep_record, started_at: 2.hours.ago) }

      it 'is valid when ended_at is after started_at' do
        sleep_record.ended_at = 1.hour.ago
        expect(sleep_record).to be_valid
      end

      it 'is invalid when ended_at is before started_at' do
        sleep_record.ended_at = 3.hours.ago
        expect(sleep_record).not_to be_valid
        expect(sleep_record.errors[:ended_at]).to include('must be after started_at')
      end

      it 'is invalid when ended_at equals started_at' do
        sleep_record.ended_at = sleep_record.started_at
        expect(sleep_record).not_to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:completed_record) { create(:sleep_record, :completed) }
    let!(:ongoing_record) { create(:sleep_record, :ongoing) }
    let!(:old_record) { create(:sleep_record, started_at: 2.weeks.ago, ended_at: 2.weeks.ago + 8.hours) }
    let!(:recent_record) { create(:sleep_record, :from_last_week) }

    describe '.completed' do
      it 'returns only completed sleep records' do
        expect(SleepRecord.completed).to include(completed_record)
        expect(SleepRecord.completed).not_to include(ongoing_record)
      end
    end

    describe '.ongoing' do
      it 'returns only ongoing sleep records' do
        expect(SleepRecord.ongoing).to include(ongoing_record)
        expect(SleepRecord.ongoing).not_to include(completed_record)
      end
    end

    describe '.from_past_week' do
      it 'returns records from the past week' do
        expect(SleepRecord.from_past_week).to include(recent_record)
        expect(SleepRecord.from_past_week).not_to include(old_record)
      end
    end
  end

  describe 'callbacks' do
    describe '#calculate_duration' do
      let(:sleep_record) { build(:sleep_record, started_at: 10.hours.ago, ended_at: 2.hours.ago) }

      it 'calculates duration when saved with ended_at' do
        sleep_record.save
        expect(sleep_record.duration).to eq(8.hours.to_i)
      end

      it 'does not calculate duration for ongoing records' do
        ongoing_record = build(:sleep_record, :ongoing)
        ongoing_record.save
        expect(ongoing_record.duration).to be_nil
      end
    end
  end
end
