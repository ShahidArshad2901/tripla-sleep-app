class CreateSleepRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.integer :duration

      t.timestamps
    end

    add_index :sleep_records, :started_at
    add_index :sleep_records, :ended_at
    add_index :sleep_records, [ :user_id, :started_at ]
  end
end
