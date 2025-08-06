# Good Night App API

A RESTful API for tracking sleep patterns and following other users' sleep habits.

## Setup

### Prerequisites
- Ruby 3.1.1
- PostgreSQL
- Rails 7.2.2

### Installation
```bash
# Clone the repository
git clone https://github.com/ShahidArshad2901/tripla-sleep-app.git
cd good_night_app

# Install dependencies
bundle install

# Setup database
cp .env.example .env
# Edit .env with your database credentials

rails db:create
rails db:migrate
rails db:seed # Creates sample data
```


## Running the application
```bash
rails server
```
The API will be available at http://localhost:3000


## Run migrations and tests
```
rails db:migrate
```
```
bundle exec rspec
```

## API Documentation
Base URL
```
http://localhost:3000/api/v1
```


## Endpoints
### 1. Get User's Sleep Records
```
GET /api/v1/sleep_records?user_id={user_id}
```

Returns all sleep records for a specific user, ordered by creation time (newest first).

### Parameters:

`user_id (required): ID of the user`

### Response:
```
[
    {
        "id": 10,
        "user_id": 1,
        "started_at": "2025-08-04T12:02:41.997Z",
        "ended_at": null,
        "duration": null,
        "created_at": "2025-08-04T12:02:41.998Z",
        "user": {
            "id": 1,
            "name": "John Doe",
            "created_at": "2025-08-04T11:34:49.983Z"
        }
    },
]
```

## 2. Clock In (Start Sleep)
```
POST /api/v1/sleep_records/clock_in?user_id={user_id}
```
Starts a new sleep session. If there's an ongoing session, it will be automatically closed.

### Parameters:

`user_id (required): ID of the user`

### Response:
Returns the user's recent sleep records (Status: 201 Created)


## 3. Follow a User
```
POST /api/v1/users/{user_id}/follow?follower_id={follower_id}
```

Creates a follow relationship between users.
### Parameters:

`user_id (required): ID of the user to follow`
`follower_id (required): ID of the follower`

### Response:
```
{
  "message": "Successfully followed {user_name}"
}
```

## 4. Unfollow a User
```
DELETE /api/v1/users/{user_id}/unfollow?follower_id={follower_id}
```

Removes a follow relationship.
### Parameters:

`user_id (required): ID of the user to unfollow`
`follower_id (required): ID of the follower`

### Response:
```
{
  "message": "Successfully unfollowed {user_name}"
}
```

## 5. Get Following Users' Sleep Records
```
GET /api/v1/sleep_records/following?user_id={user_id}
```
Returns sleep records from all followed users from the past week, sorted by duration.

### Parameters:

`user_id (required): ID of the user`

### Response:
```
[
    {
        "id": 2,
        "user_id": 2,
        "user_name": "Jane Smith",
        "started_at": "2025-08-02T23:00:00.000Z",
        "ended_at": "2025-08-03T07:00:00.000Z",
        "duration": 28800,
        "duration_in_hours": "8h 0m",
        "created_at": "2025-08-04T11:34:50.031Z"
    }
]
```

### Pagination

All list endpoints support pagination:

**Parameters:**
- `page` (optional): Page number (default: 1)
- `per_page` (optional): Items per page (default: 20, max: 100)

**Response includes meta:**
```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 5,
    "total_count": 95
  }
}

## Error Responses

### 404 Not Found
```
{
  "error": "Couldn't find User with 'id'=999"
}
```

### 422 Unprocessable Entity

```
{
  "error": ["Follower has already been taken"]
}
```

## Performance Considerations

1. Database Indexes: Added indexes on foreign keys and commonly queried fields
2. Query Optimization: Uses includes to prevent N+1 queries
3. Response Limits: API responses are limited to prevent large payloads
4. Transaction Safety: Clock-in operations are wrapped in transactions

## Testing
### Run the test suite:
```
bundle exec rspec
```

## Architecture Decisions

1. API-only Rails: Lightweight, focused on JSON responses
2. PostgreSQL: Reliable, handles concurrent operations well
3. Service Objects: Not needed for current scope but easy to add
4. Serializers: Using ActiveModel::Serializers for consistent JSON output
5. No Authentication: As per requirements, but easy to add later
