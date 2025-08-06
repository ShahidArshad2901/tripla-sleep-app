class AddPerformanceIndexes < ActiveRecord::Migration[7.2]
  def change
    add_index :sleep_records, [ :user_id, :started_at, :duration ]

    add_index :sleep_records, [ :ended_at, :duration ], where: "ended_at IS NOT NULL"
  end
end
