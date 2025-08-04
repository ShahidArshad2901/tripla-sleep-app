# Create sample users
user1 = User.create!(name: "John Doe")
user2 = User.create!(name: "Jane Smith")
user3 = User.create!(name: "Bob Johnson")

# Create some sleep records
user1.sleep_records.create!(started_at: 1.day.ago.at_beginning_of_day + 22.hours, ended_at: Time.current.at_beginning_of_day + 6.hours)
user2.sleep_records.create!(started_at: 2.days.ago.at_beginning_of_day + 23.hours, ended_at: 1.day.ago.at_beginning_of_day + 7.hours)
user3.sleep_records.create!(started_at: 8.hours.ago) # Ongoing

# Create follow relationships
Follow.create!(follower: user1, following: user2)
Follow.create!(follower: user1, following: user3)

puts "Seed data created!"
puts "User IDs: #{User.pluck(:id, :name)}"
