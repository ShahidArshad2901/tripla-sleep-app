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

```
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
```
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


## Key Assumptions & Design Decisions

### Business Logic Assumptions

1. **Clock-In Behavior**
   - When a user clocks in while having an ongoing sleep session, the system automatically closes the previous session
   - This prevents overlapping sleep records and handles cases where users forget to "clock out"
   - Sleep duration is calculated and stored when a session ends for query performance

2. **Sleep Session Definition**
   - A sleep session starts with a "clock in" (going to bed) and ends when the user clocks in again (waking up and starting a new day)
   - Sessions can span multiple days (e.g., sleeping from 11 PM to 7 AM)
   - There's no explicit "clock out" - the next clock in ends the previous session

3. **Following Records Time Frame**
   - "Previous week" means the last 7 days from the current date (rolling window)
   - Only completed sleep sessions are shown (ongoing sessions are excluded)
   - Records are sorted by duration in descending order (longest sleep first)

4. **User Identification**
   - No authentication is implemented as per requirements
   - Users are identified only by their ID in request parameters
   - In a production system, this would need proper authentication

5. **API Response Limits**
   - Paginated responses default to 20 items per page (max 100)
   - Following sleep records are limited to prevent massive responses
   - Recent sleep records on clock-in show only the last 10 entries

### Technical Decisions

1. **Database Choice**
   - PostgreSQL for reliable concurrent operations and excellent timestamp handling
   - Indexes added on foreign keys and commonly queried fields for performance

2. **No Background Jobs**
   - Duration calculation happens synchronously on save
   - In a high-traffic system, this could be moved to background processing

3. **Caching Strategy**
   - Currently using in-memory caching for rate limiting only
   - Database queries are optimized with includes() to prevent N+1
   - Redis could be added for caching frequently accessed data

4. **Error Handling**
   - All errors return consistent JSON responses
   - 404 for not found resources
   - 422 for validation errors
   - 429 for rate limit exceeded

5. **Time Zones**
   - All timestamps are stored and returned in UTC
   - Client applications should handle timezone conversion

## Scalability Considerations

1. **Database Performance**
   - Composite indexes on (user_id, started_at) for efficient filtering
   - Pagination prevents loading large datasets
   - Duration is pre-calculated and indexed

2. **API Rate Limiting**
   - 100 requests per 5 minutes per IP (general)
   - 10 clock-ins per hour per user (prevent abuse)
   - Uses in-memory store (could upgrade to Redis)

3. **Future Enhancements**
   - Add caching layer for following users' sleep records
   - Implement database read replicas for scaling reads
   - Add background job processing for heavy computations
   - Consider GraphQL for more efficient data fetching

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
