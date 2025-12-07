# UniPool REST API Documentation

Complete API reference documentation for the UniPool Backend service.

## Table of Contents

- [Base URL and Authentication](#base-url-and-authentication)
- [Rate Limiting](#rate-limiting)
- [Error Response Format](#error-response-format)
- [Authentication Endpoints](#authentication-endpoints)
- [User Management](#user-management)
- [Vehicle Management](#vehicle-management)
- [Location Management](#location-management)
- [Routing and Distance Calculation](#routing-and-distance-calculation)
- [Ride Management](#ride-management)
- [GPS Tracking](#gps-tracking)
- [Booking Management](#booking-management)
- [Payment Management](#payment-management)
- [Rating System](#rating-system)
- [Notifications](#notifications)
- [Analytics](#analytics)
- [Moderation](#moderation)
- [Admin Endpoints](#admin-endpoints)
- [Permissions Matrix](#permissions-matrix)
- [Data Models](#data-models)
- [JWT Token Decoding](#jwt-token-decoding)
- [Pagination and Filtering](#pagination-and-filtering)

---

## Base URL and Authentication

**Base URL:** `http://localhost:8080/api`

**Authentication:** Most endpoints require JWT authentication. Include the token in the `Authorization` header:

```
Authorization: Bearer <your-jwt-token>
```

**Public Endpoints** (no authentication required):
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/health`

**Token Expiration:** 24 hours (86400000 milliseconds)

---

## Rate Limiting

The API implements rate limiting using Bucket4j:

- **General API endpoints**: 100 requests per minute per IP address
- **Authentication endpoints** (`/api/auth/login`, `/api/auth/register`): 5 requests per minute per IP address

Rate limiting can be enabled or disabled via configuration:

```properties
rate.limiting.enabled=true  # Set to false to disable rate limiting
```

**Note:** Rate limiting is enabled by default. Set `rate.limiting.enabled=false` in `application.properties` to disable it during testing.

When rate limit is exceeded, the API returns:

**Status Code:** `429 Too Many Requests`

**Response:**
```json
{
  "error": "Too many requests. Please try again later."
}
```

---

## Error Response Format

All error responses follow this structure:

```json
{
  "message": "Error description",
  "status": 400,
  "timestamp": "2024-01-15T10:30:00.123Z",
  "fieldName": "Validation error message (if applicable)"
}
```

### Common Status Codes

- **200 OK**: Request successful
- **201 Created**: Resource created successfully
- **400 Bad Request**: Invalid request data or validation errors
- **401 Unauthorized**: Authentication required or invalid token
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Resource not found
- **409 Conflict**: Resource conflict (e.g., duplicate email)
- **429 Too Many Requests**: Rate limit exceeded
- **500 Internal Server Error**: Server error

---

## Authentication Endpoints

### POST /api/auth/register

Register a new user account.

**Authentication:** Not required

**Request Body:**
```json
{
  "universityId": "S123456",
  "email": "user@university.edu",
  "password": "SecurePass123!",
  "fullName": "John Doe",
  "phoneNumber": "+1234567890",
  "role": "RIDER"
}
```

**Field Validation:**
- `universityId` (required): String, max 300 characters
- `email` (required): Valid email format, max 320 characters
- `password` (required): Min 8 characters, must contain at least one letter, one number, and one special character (@$!%*?&#)
- `fullName` (required): String, max 300 characters
- `phoneNumber` (optional): E.164 format (e.g., +1234567890), max 30 characters
- `role` (optional): `RIDER`, `DRIVER`, or `BOTH` (default: `RIDER`). **ADMIN role cannot be assigned during registration**

**Response:** `201 Created`
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "universityId": "S123456",
    "email": "user@university.edu",
    "fullName": "John Doe",
    "phoneNumber": "+1234567890",
    "role": "RIDER",
    "enabled": true,
    "createdAt": "2024-01-15T10:30:00",
    "walletBalance": 0.00,
    "avgRatingAsDriver": null,
    "ratingCountAsDriver": 0,
    "avgRatingAsRider": null,
    "ratingCountAsRider": 0
  }
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "universityId": "S123456",
    "email": "user@university.edu",
    "password": "SecurePass123!",
    "fullName": "John Doe",
    "role": "RIDER"
  }'
```

**Error Responses:**
- `400 Bad Request`: Validation errors
- `409 Conflict`: Email or university ID already exists

---

### POST /api/auth/login

Authenticate user and receive JWT token.

**Authentication:** Not required

**Request Body:**
```json
{
  "email": "user@university.edu",
  "password": "SecurePass123!"
}
```

**Field Validation:**
- `email` (required): Valid email format
- `password` (required): User password

**Response:** `200 OK`
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "universityId": "S123456",
    "email": "user@university.edu",
    "fullName": "John Doe",
    "role": "RIDER",
    "enabled": true,
    "walletBalance": 0.00
  }
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@university.edu",
    "password": "SecurePass123!"
  }'
```

**Error Responses:**
- `401 Unauthorized`: Invalid credentials
- `400 Bad Request`: Validation errors

---

### POST /api/auth/logout

Logout user (invalidates token on client side).

**Authentication:** Required

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/auth/logout \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/auth/me

Get current authenticated user's profile.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "id": 1,
  "universityId": "S123456",
  "email": "user@university.edu",
  "fullName": "John Doe",
  "phoneNumber": "+1234567890",
  "role": "RIDER",
  "enabled": true,
  "createdAt": "2024-01-15T10:30:00",
  "walletBalance": 0.00,
  "avgRatingAsDriver": null,
  "ratingCountAsDriver": 0,
  "avgRatingAsRider": null,
  "ratingCountAsRider": 0
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

---

## User Management

### GET /api/users/me

Get current user's profile.

**Authentication:** Required

**Response:** `200 OK` (UserResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/users/me \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/users/{id}

Get user by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): User ID

**Response:** `200 OK` (UserResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/users/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### PUT /api/users/me

Update current user's profile.

**Authentication:** Required

**Request Body:**
```json
{
  "fullName": "John Updated Doe",
  "phoneNumber": "+1234567891"
}
```

**Field Validation:**
- `fullName` (required): String, max 300 characters
- `phoneNumber` (optional): E.164 format, max 30 characters

**Response:** `200 OK` (UserResponse)

**cURL Example:**
```bash
curl -X PUT http://localhost:8080/api/users/me \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "John Updated Doe",
    "phoneNumber": "+1234567891"
  }'
```

---

### PUT /api/users/me/password

Change current user's password.

**Authentication:** Required

**Request Body:**
```json
{
  "oldPassword": "OldPass123!",
  "newPassword": "NewPass456!"
}
```

**Field Validation:**
- `oldPassword` (required): Current password
- `newPassword` (required): Min 8 characters, must contain at least one letter, one number, and one special character

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X PUT http://localhost:8080/api/users/me/password \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "oldPassword": "OldPass123!",
    "newPassword": "NewPass456!"
  }'
```

**Error Responses:**
- `400 Bad Request`: Invalid old password

---

### PUT /api/users/me/role

Update current user's role.

**Authentication:** Required

**Request Body:**
```json
{
  "role": "BOTH"
}
```

**Field Validation:**
- `role` (required): `RIDER`, `DRIVER`, or `BOTH` (ADMIN cannot be set)

**Response:** `200 OK` (UserResponse)

**cURL Example:**
```bash
curl -X PUT http://localhost:8080/api/users/me/role \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "BOTH"
  }'
```

---

### GET /api/users/me/settings

Get current user's settings.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "emailNotifications": true,
  "smsNotifications": false,
  "pushNotifications": true,
  "allowSmoking": false,
  "allowPets": true,
  "allowMusic": true,
  "preferQuietRides": false,
  "showPhoneNumber": true,
  "showEmail": false,
  "autoAcceptBookings": false,
  "preferredPaymentMethod": "WALLET"
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/users/me/settings \
  -H "Authorization: Bearer $TOKEN"
```

---

### PUT /api/users/me/settings

Update current user's settings.

**Authentication:** Required

**Request Body:**
```json
{
  "emailNotifications": true,
  "smsNotifications": false,
  "pushNotifications": true,
  "allowSmoking": false,
  "allowPets": true,
  "allowMusic": true,
  "preferQuietRides": false,
  "showPhoneNumber": true,
  "showEmail": false,
  "autoAcceptBookings": false,
  "preferredPaymentMethod": "WALLET"
}
```

**Field Validation:**
- All fields are optional (boolean or string)
- `preferredPaymentMethod`: `CARD_SIMULATED`, `CASH`, or `WALLET`

**Response:** `200 OK` (UserSettingsResponse)

**cURL Example:**
```bash
curl -X PUT http://localhost:8080/api/users/me/settings \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "emailNotifications": true,
    "preferredPaymentMethod": "WALLET"
  }'
```

---

### GET /api/users/me/stats

Get current user's statistics.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "totalRidesAsDriver": 10,
  "totalRidesAsRider": 25,
  "totalBookings": 25,
  "totalEarnings": 500.00,
  "totalSpent": 300.00,
  "avgRatingAsDriver": 4.5,
  "avgRatingAsRider": 4.8
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/users/me/stats \
  -H "Authorization: Bearer $TOKEN"
```

---

## Vehicle Management

### POST /api/vehicles

Create a new vehicle.

**Authentication:** Required (DRIVER or BOTH role)

**Request Body:**
```json
{
  "make": "Toyota",
  "model": "Camry",
  "color": "Blue",
  "plateNumber": "ABC-1234",
  "seatCount": 4
}
```

**Field Validation:**
- `make` (required): String, max 100 characters
- `model` (required): String, max 100 characters
- `color` (optional): String, max 100 characters
- `plateNumber` (required): String, max 50 characters
- `seatCount` (required): Positive integer

**Response:** `201 Created` (VehicleResponse)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/vehicles \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "make": "Toyota",
    "model": "Camry",
    "color": "Blue",
    "plateNumber": "ABC-1234",
    "seatCount": 4
  }'
```

---

### GET /api/vehicles/{id}

Get vehicle by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Vehicle ID

**Response:** `200 OK` (VehicleResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/vehicles/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/vehicles/me

Get all vehicles owned by current user.

**Authentication:** Required

**Response:** `200 OK` (array of VehicleResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/vehicles/me \
  -H "Authorization: Bearer $TOKEN"
```

---

### PUT /api/vehicles/{id}

Update vehicle.

**Authentication:** Required (Vehicle owner)

**Request Body:**
```json
{
  "make": "Honda",
  "model": "Accord",
  "color": "Red",
  "plateNumber": "XYZ-5678",
  "seatCount": 5
}
```

**Field Validation:**
- All fields optional
- `seatCount`: Positive integer if provided

**Response:** `200 OK` (VehicleResponse)

**cURL Example:**
```bash
curl -X PUT http://localhost:8080/api/vehicles/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "make": "Honda",
    "model": "Accord"
  }'
```

---

### DELETE /api/vehicles/{id}

Delete a vehicle.

**Authentication:** Required (Vehicle owner)

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X DELETE http://localhost:8080/api/vehicles/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

## Location Management

### POST /api/locations

Create a location.

**Authentication:** Required

**Request Body:**
```json
{
  "label": "Home",
  "address": "123 Main St, City, State 12345",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "isFavorite": true
}
```

**Field Validation:**
- `label` (required): String, max 200 characters
- `address` (optional): String, max 500 characters
- `latitude` (required): Number between -90 and 90
- `longitude` (required): Number between -180 and 180
- `isFavorite` (optional): Boolean

**Response:** `201 Created` (LocationResponse)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/locations \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "Home",
    "address": "123 Main St",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "isFavorite": true
  }'
```

---

### GET /api/locations/{id}

Get location by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Location ID

**Response:** `200 OK` (LocationResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/locations/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/locations/me

Get all locations for current user.

**Authentication:** Required

**Response:** `200 OK` (array of LocationResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/locations/me \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/locations/me/favorites

Get favorite locations for current user.

**Authentication:** Required

**Response:** `200 OK` (array of LocationResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/locations/me/favorites \
  -H "Authorization: Bearer $TOKEN"
```

---

### PUT /api/locations/{id}

Update location.

**Authentication:** Required (Location owner)

**Request Body:** Same as POST /api/locations

**Response:** `200 OK` (LocationResponse)

**cURL Example:**
```bash
curl -X PUT http://localhost:8080/api/locations/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "Updated Home",
    "latitude": 40.7130,
    "longitude": -74.0062
  }'
```

---

### DELETE /api/locations/{id}

Delete location.

**Authentication:** Required (Location owner)

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X DELETE http://localhost:8080/api/locations/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/locations/distance

Calculate distance between two locations.

**Authentication:** Required

**Request Body:**
```json
{
  "locationAId": 1,
  "locationBId": 2
}
```

**Field Validation:**
- `locationAId` (required): Location ID
- `locationBId` (required): Location ID

**Note:** This endpoint uses OSRM for route-based distance calculation. If OSRM is unavailable, it falls back to Haversine (straight-line) distance. See [Routing and Distance Calculation](#routing-and-distance-calculation) for more details.

**Response:** `200 OK`
```json
{
  "distanceKm": 5.2,
  "distanceMiles": 3.23
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/locations/distance \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "locationAId": 1,
    "locationBId": 2
  }'
```

---

### POST /api/locations/search

Search for locations by query string.

**Authentication:** Required

**Request Body:**
```json
{
  "query": "Times Square, New York"
}
```

**Field Validation:**
- `query` (required): Search query string

**Response:** `200 OK` (array of location objects)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/locations/search \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Times Square"
  }'
```

---

### GET /api/locations/reverse-geocode

Get address from coordinates.

**Authentication:** Required

**Query Parameters:**
- `latitude` (required): Latitude (-90 to 90)
- `longitude` (required): Longitude (-180 to 180)

**Response:** `200 OK`
```json
{
  "address": "123 Main St, New York, NY 10001"
}
```

**cURL Example:**
```bash
curl -X GET "http://localhost:8080/api/locations/reverse-geocode?latitude=40.7128&longitude=-74.0060" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Routing and Distance Calculation

The backend uses **OSRM (Open Source Routing Machine)** for accurate route calculation and distance estimation. The system automatically falls back to Haversine distance calculation if OSRM is unavailable.

### Routing Service

**OSRM Integration:**
- Uses the public OSRM service (`router.project-osrm.org`) for route calculation
- Calculates road-based distances and estimated travel times
- Provides route geometry (polyline) for map visualization
- Connection timeout: 2 seconds
- Read timeout: 3 seconds

**Fallback Behavior:**
- If OSRM is unavailable or times out, the system automatically falls back to Haversine distance calculation
- Haversine calculates straight-line (as-the-crow-flies) distance between coordinates
- Estimated duration is calculated using an average speed of 40 km/h

**Endpoints Using Routing:**
- `POST /api/rides` - Calculates route distance and duration when creating a ride
- `PUT /api/rides/{id}` - Recalculates route if locations are updated
- `POST /api/locations/distance` - Calculates distance between two locations

**Performance:**
- OSRM requests typically complete in < 1 second when available
- If OSRM is unavailable, fallback to Haversine is nearly instantaneous
- Route calculation may add 1-3 seconds to ride creation requests

**Note:** Route distances and durations are estimates based on road networks. Actual travel times may vary based on traffic conditions, which are not currently factored into calculations.

---

## Ride Management

### POST /api/rides

Create a new ride.

**Authentication:** Required (DRIVER or BOTH role)

**Request Body:**
```json
{
  "vehicleId": 1,
  "pickupLocationId": 1,
  "destinationLocationId": 2,
  "departureTimeStart": "2024-12-15T14:30:00",
  "departureTimeEnd": "2024-12-15T14:45:00",
  "totalSeats": 4,
  "basePrice": 10.00,
  "pricePerSeat": 5.00
}
```

**Field Validation:**
- `vehicleId` (required): Vehicle ID (must belong to user)
- `pickupLocationId` (required): Location ID
- `destinationLocationId` (required): Location ID
- `departureTimeStart` (required): Start of departure time window - Future datetime (ISO format)
- `departureTimeEnd` (required): End of departure time window - Future datetime (ISO format), must be after start
- `totalSeats` (required): Positive integer
- `basePrice` (optional): Positive decimal
- `pricePerSeat` (optional): Positive decimal

**Note:** 
- Rides require both `departureTimeStart` and `departureTimeEnd` to define the departure time window.
- Route distance and estimated duration are automatically calculated using OSRM when creating a ride. See [Routing and Distance Calculation](#routing-and-distance-calculation) for more details.

**Response:** `201 Created` (RideResponse)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/rides \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicleId": 1,
    "pickupLocationId": 1,
    "destinationLocationId": 2,
    "departureTimeStart": "2024-12-15T14:30:00",
    "departureTimeEnd": "2024-12-15T14:45:00",
    "totalSeats": 4,
    "pricePerSeat": 5.00
  }'
```

---

### GET /api/rides/{id}

Get ride by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Ride ID

**Response:** `200 OK` (RideResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/rides/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/rides/search

Search for available rides with filters.

**Authentication:** Required

**Request Body:**
```json
{
  "pickupLocationId": 1,
  "pickupLatitude": 40.7128,
  "pickupLongitude": -74.0060,
  "pickupRadiusKm": 5.0,
  "destinationLocationId": 2,
  "destinationLatitude": 40.7580,
  "destinationLongitude": -73.9855,
  "destinationRadiusKm": 5.0,
  "departureTimeFrom": "2024-12-15T00:00:00",
  "departureTimeTo": "2024-12-15T23:59:59",
  "minAvailableSeats": 1,
  "maxPrice": 50.00,
  "sortBy": "price"
}
```

**Field Validation:**
- All fields optional
- Use either `pickupLocationId` OR `pickupLatitude`/`pickupLongitude`/`pickupRadiusKm`
- Use either `destinationLocationId` OR `destinationLatitude`/`destinationLongitude`/`destinationRadiusKm`
- `sortBy`: `distance`, `price`, or `departureTime`
- **Time Range Overlap**: The search uses overlapping time range detection. A ride will be returned if its departure time range overlaps with the search time range. For example:
  - Ride: 7:00 - 8:30
  - Search: 6:30 - 7:30 → **Matches** (overlaps)
  - Search: 8:00 - 9:00 → **Matches** (overlaps)
  - Search: 5:00 - 6:00 → **No match** (no overlap)

**Response:** `200 OK` (array of RideResponse)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/rides/search \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "pickupLocationId": 1,
    "destinationLocationId": 2,
    "departureTimeFrom": "2024-12-15T00:00:00Z",
    "minAvailableSeats": 1,
    "sortBy": "price"
  }'
```

---

### GET /api/rides/driver/{driverId}

Get rides by driver ID.

**Authentication:** Required

**Path Parameters:**
- `driverId` (required): Driver user ID

**Response:** `200 OK` (array of RideResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/rides/driver/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/rides/me/driver

Get current user's rides as driver.

**Authentication:** Required (DRIVER or BOTH role)

**Response:** `200 OK` (array of RideResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/rides/me/driver \
  -H "Authorization: Bearer $TOKEN"
```

---

### PUT /api/rides/{id}

Update ride.

**Authentication:** Required (Ride owner/Driver)

**Request Body:**
```json
{
  "pickupLocationId": 3,
  "destinationLocationId": 4,
  "departureTimeStart": "2024-12-15T15:00:00",
  "departureTimeEnd": "2024-12-15T15:15:00",
  "totalSeats": 5,
  "basePrice": 12.00,
  "pricePerSeat": 6.00
}
```

**Field Validation:**
- All fields optional
- If provided, `departureTimeStart` and `departureTimeEnd` must be future dates

**Response:** `200 OK` (RideResponse)

**cURL Example:**
```bash
curl -X PUT http://localhost:8080/api/rides/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "totalSeats": 5,
    "pricePerSeat": 6.00
  }'
```

---

### PATCH /api/rides/{id}/status

Update ride status.

**Authentication:** Required (Ride owner/Driver)

**Request Body:**
```json
{
  "status": "IN_PROGRESS"
}
```

**Field Validation:**
- `status` (required): `SCHEDULED`, `IN_PROGRESS`, `COMPLETED`, or `CANCELLED`

**Response:** `200 OK` (RideResponse)

**cURL Example:**
```bash
curl -X PATCH http://localhost:8080/api/rides/1/status \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "IN_PROGRESS"
  }'
```

---

### DELETE /api/rides/{id}

Cancel a ride.

**Authentication:** Required (Ride owner/Driver)

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X DELETE http://localhost:8080/api/rides/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/rides/{id}/available-seats

Get available seats for a ride.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Ride ID

**Response:** `200 OK`
```json
2
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/rides/1/available-seats \
  -H "Authorization: Bearer $TOKEN"
```

---

## GPS Tracking

### POST /api/tracking/{rideId}/start

Start GPS tracking for a ride.

**Authentication:** Required (Ride owner/Driver only)

**Path Parameters:**
- `rideId` (required): Ride ID

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/tracking/1/start \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/tracking/{rideId}/update

Update current GPS location during ride.

**Authentication:** Required (Ride owner/Driver only)

**Path Parameters:**
- `rideId` (required): Ride ID

**Request Body:**
```json
{
  "latitude": 40.7128,
  "longitude": -74.0060
}
```

**Field Validation:**
- `latitude` (required): Number between -90 and 90
- `longitude` (required): Number between -180 and 180

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/tracking/1/update \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 40.7128,
    "longitude": -74.0060
  }'
```

---

### GET /api/tracking/{rideId}

Get current GPS location of active ride.

**Authentication:** Required

**Path Parameters:**
- `rideId` (required): Ride ID

**Response:** `200 OK`
```json
{
  "latitude": 40.7128,
  "longitude": -74.0060,
  "timestamp": "2024-01-15T10:30:00"
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/tracking/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/tracking/{rideId}/stop

Stop GPS tracking for a ride.

**Authentication:** Required (Ride owner/Driver only)

**Path Parameters:**
- `rideId` (required): Ride ID

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/tracking/1/stop \
  -H "Authorization: Bearer $TOKEN"
```

---

## Booking Management

### POST /api/bookings

Create a booking for a ride.

**Authentication:** Required (RIDER or BOTH role)

**Request Body:**
```json
{
  "rideId": 1,
  "seats": 2,
  "pickupLocationId": 1,
  "dropoffLocationId": 2,
  "pickupTimeStart": "2024-12-15T14:30:00",
  "pickupTimeEnd": "2024-12-15T14:45:00"
}
```

**Field Validation:**
- `rideId` (required): Ride ID
- `seats` (required): Positive integer (must not exceed available seats)
- `pickupLocationId` (required): Location ID
- `dropoffLocationId` (required): Location ID
- `pickupTimeStart` (required): Start of pickup time window - Future datetime (ISO format)
- `pickupTimeEnd` (required): End of pickup time window - Future datetime (ISO format), must be after start

**Note:** Bookings require both `pickupTimeStart` and `pickupTimeEnd` to define the pickup time window. The pickup time window must be within the ride's departure time window.

**Response:** `201 Created` (RideResponse)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/bookings \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "rideId": 1,
    "seats": 2,
    "pickupLocationId": 1,
    "dropoffLocationId": 2,
    "pickupTimeStart": "2024-12-15T14:30:00",
    "pickupTimeEnd": "2024-12-15T14:45:00"
  }'
```

**Error Responses:**
- `400 Bad Request`: Not enough available seats
- `409 Conflict`: User already has a booking for this ride

---

### GET /api/bookings/{id}

Get booking by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Booking ID

**Response:** `200 OK` (BookingResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/bookings/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/bookings/me

Get all bookings for current user.

**Authentication:** Required

**Response:** `200 OK` (array of BookingResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/bookings/me \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/bookings/rider/{riderId}

Get bookings for a specific rider.

**Authentication:** Required

**Path Parameters:**
- `riderId` (required): Rider user ID

**Response:** `200 OK` (array of BookingResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/bookings/rider/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/bookings/ride/{rideId}

Get all bookings for a specific ride (Driver only).

**Authentication:** Required (Ride owner/Driver)

**Path Parameters:**
- `rideId` (required): Ride ID

**Response:** `200 OK` (array of BookingResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/bookings/ride/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/bookings/{bookingId}/cancel

Cancel a booking.

**Authentication:** Required (Booking owner or Ride driver)

**Path Parameters:**
- `bookingId` (required): Booking ID

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/bookings/1/cancel \
  -H "Authorization: Bearer $TOKEN"
```

---

## Payment Management

### POST /api/payments/initiate

Initiate payment for a booking.

**Authentication:** Required

**Request Body:**
```json
{
  "bookingId": 1,
  "method": "WALLET"
}
```

**Field Validation:**
- `bookingId` (required): Booking ID
- `method` (required): `CARD_SIMULATED`, `CASH`, or `WALLET`

**Response:** `201 Created` (PaymentResponse)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/payments/initiate \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bookingId": 1,
    "method": "WALLET"
  }'
```

**Error Responses:**
- `400 Bad Request`: Insufficient wallet balance (for WALLET method)
- `409 Conflict`: Payment already exists for booking

---

### GET /api/payments/{id}

Get payment by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Payment ID

**Response:** `200 OK` (PaymentResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/payments/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/payments/me

Get all payments for current user.

**Authentication:** Required

**Response:** `200 OK` (array of PaymentResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/payments/me \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/payments/me/driver

Get payments received as driver.

**Authentication:** Required (DRIVER or BOTH role)

**Response:** `200 OK` (array of PaymentResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/payments/me/driver \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/payments/user/{userId}

Get payments for a specific user.

**Authentication:** Required

**Path Parameters:**
- `userId` (required): User ID

**Response:** `200 OK` (array of PaymentResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/payments/user/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/payments/booking/{bookingId}

Get payments for a specific booking.

**Authentication:** Required

**Path Parameters:**
- `bookingId` (required): Booking ID

**Response:** `200 OK` (array of PaymentResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/payments/booking/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/payments/{id}/process

Process a payment (mark as processed).

**Authentication:** Required

**Path Parameters:**
- `id` (required): Payment ID

**Response:** `200 OK` (PaymentResponse)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/payments/1/process \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/payments/{id}/refund

Refund a payment.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Payment ID

**Response:** `200 OK` (PaymentResponse)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/payments/1/refund \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/payments/wallet/balance

Get current wallet balance.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "balance": 100.00
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/payments/wallet/balance \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/payments/wallet/topup

Top up wallet balance.

**Authentication:** Required

**Request Body:**
```json
{
  "amount": 100.00
}
```

**Field Validation:**
- `amount` (required): Positive decimal

**Response:** `200 OK` (PaymentResponse)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/payments/wallet/topup \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100.00
  }'
```

---

## Rating System

### POST /api/ratings

Create a rating for a completed booking.

**Authentication:** Required

**Request Body:**
```json
{
  "bookingId": 1,
  "score": 5,
  "comment": "Great driver, very punctual!"
}
```

**Field Validation:**
- `bookingId` (required): Booking ID (must be completed)
- `score` (required): Integer between 1 and 5
- `comment` (optional): String, max 2000 characters

**Response:** `201 Created` (RatingResponse)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/ratings \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bookingId": 1,
    "score": 5,
    "comment": "Great driver!"
  }'
```

**Error Responses:**
- `400 Bad Request`: Booking not completed or already rated
- `403 Forbidden`: Cannot rate own booking

---

### GET /api/ratings/{id}

Get rating by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Rating ID

**Response:** `200 OK` (RatingResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/ratings/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/ratings/user/{userId}

Get all ratings for a user.

**Authentication:** Required

**Path Parameters:**
- `userId` (required): User ID

**Response:** `200 OK` (array of RatingResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/ratings/user/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/ratings/me/given

Get ratings given by current user.

**Authentication:** Required

**Response:** `200 OK` (array of RatingResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/ratings/me/given \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/ratings/booking/{bookingId}

Get rating for a specific booking.

**Authentication:** Required

**Path Parameters:**
- `bookingId` (required): Booking ID

**Response:** `200 OK` (RatingResponse) or `404 Not Found` if no rating exists

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/ratings/booking/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

## Notifications

### GET /api/notifications/me

Get all notifications for current user.

**Authentication:** Required

**Response:** `200 OK` (array of NotificationResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/notifications/me \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/notifications/me/unread

Get unread notifications for current user.

**Authentication:** Required

**Response:** `200 OK` (array of NotificationResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/notifications/me/unread \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/notifications/me/unread-count

Get count of unread notifications.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "count": 5
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/notifications/me/unread-count \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/notifications/{id}/read

Mark a notification as read.

**Authentication:** Required (Notification owner)

**Path Parameters:**
- `id` (required): Notification ID

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/notifications/1/read \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/notifications/me/read-all

Mark all notifications as read for current user.

**Authentication:** Required

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/notifications/me/read-all \
  -H "Authorization: Bearer $TOKEN"
```

---

## Analytics

### GET /api/analytics/driver/earnings

Get driver earnings statistics.

**Authentication:** Required (DRIVER or BOTH role)

**Query Parameters:**
- `from` (optional): Start date (ISO format: YYYY-MM-DD)
- `to` (optional): End date (ISO format: YYYY-MM-DD)

**Response:** `200 OK`
```json
{
  "totalEarnings": 500.00,
  "totalRides": 10,
  "averageEarningsPerRide": 50.00,
  "platformFees": 50.00,
  "period": {
    "from": "2024-01-01",
    "to": "2024-12-31"
  }
}
```

**cURL Example:**
```bash
curl -X GET "http://localhost:8080/api/analytics/driver/earnings?from=2024-01-01&to=2024-12-31" \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/analytics/rider/spending

Get rider spending statistics.

**Authentication:** Required (RIDER or BOTH role)

**Query Parameters:**
- `from` (optional): Start date (ISO format: YYYY-MM-DD)
- `to` (optional): End date (ISO format: YYYY-MM-DD)

**Response:** `200 OK`
```json
{
  "totalSpent": 300.00,
  "totalBookings": 25,
  "averageSpendingPerBooking": 12.00,
  "period": {
    "from": "2024-01-01",
    "to": "2024-12-31"
  }
}
```

**cURL Example:**
```bash
curl -X GET "http://localhost:8080/api/analytics/rider/spending?from=2024-01-01&to=2024-12-31" \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/analytics/rides/stats

Get ride statistics for current user.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "totalRidesAsDriver": 10,
  "totalRidesAsRider": 25,
  "completedRides": 30,
  "cancelledRides": 5
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/analytics/rides/stats \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/analytics/bookings/stats

Get booking statistics (Admin only).

**Authentication:** Required (ADMIN role)

**Response:** `200 OK`
```json
{
  "totalBookings": 1000,
  "confirmedBookings": 950,
  "cancelledBookings": 50,
  "pendingBookings": 10
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/analytics/bookings/stats \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/analytics/destinations/popular

Get popular destinations (Admin only).

**Authentication:** Required (ADMIN role)

**Query Parameters:**
- `limit` (optional): Number of results (default: 10)

**Response:** `200 OK`
```json
{
  "destinations": [
    {
      "locationId": 1,
      "address": "123 Main St",
      "count": 50
    }
  ]
}
```

**cURL Example:**
```bash
curl -X GET "http://localhost:8080/api/analytics/destinations/popular?limit=20" \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/analytics/times/peak

Get peak times analysis (Admin only).

**Authentication:** Required (ADMIN role)

**Response:** `200 OK`
```json
{
  "peakHours": [
    {
      "hour": 8,
      "count": 100
    }
  ]
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/analytics/times/peak \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/analytics/dashboard

Get dashboard statistics (Admin only).

**Authentication:** Required (ADMIN role)

**Response:** `200 OK`
```json
{
  "totalUsers": 1000,
  "totalRides": 5000,
  "totalBookings": 10000,
  "totalRevenue": 50000.00,
  "activeDrivers": 100,
  "activeRiders": 500
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/analytics/dashboard \
  -H "Authorization: Bearer $TOKEN"
```

---

## Moderation

### POST /api/moderation/report

Create a report for a user, ride, or booking.

**Authentication:** Required

**Request Body:**
```json
{
  "reportedUserId": 1,
  "rideId": 1,
  "bookingId": 1,
  "reportType": "INAPPROPRIATE_BEHAVIOR",
  "reason": "User was rude and unprofessional"
}
```

**Field Validation:**
- `reportedUserId` (required): User ID to report
- `rideId` (optional): Related ride ID
- `bookingId` (optional): Related booking ID
- `reportType` (required): Report type enum
- `reason` (required): String, max 2000 characters

**Response:** `201 Created` (ReportResponse)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/moderation/report \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "reportedUserId": 1,
    "reportType": "INAPPROPRIATE_BEHAVIOR",
    "reason": "User was rude"
  }'
```

---

### GET /api/moderation/reports

Get all reports (Admin only).

**Authentication:** Required (ADMIN role)

**Response:** `200 OK` (array of ReportResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/moderation/reports \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/moderation/reports/pending

Get pending reports (Admin only).

**Authentication:** Required (ADMIN role)

**Response:** `200 OK` (array of ReportResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/moderation/reports/pending \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/moderation/reports/{id}

Get report by ID (Admin only).

**Authentication:** Required (ADMIN role)

**Path Parameters:**
- `id` (required): Report ID

**Response:** `200 OK` (ReportResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/moderation/reports/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### PUT /api/moderation/reports/{id}/resolve

Resolve a report (Admin only).

**Authentication:** Required (ADMIN role)

**Path Parameters:**
- `id` (required): Report ID

**Request Body:**
```json
{
  "action": "WARNING",
  "notes": "User warned about behavior"
}
```

**Response:** `200 OK` (ReportResponse)

**cURL Example:**
```bash
curl -X PUT http://localhost:8080/api/moderation/reports/1/resolve \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "WARNING",
    "notes": "User warned"
  }'
```

---

### POST /api/moderation/users/{id}/ban

Ban a user (Admin only).

**Authentication:** Required (ADMIN role)

**Path Parameters:**
- `id` (required): User ID

**Request Body:**
```json
{
  "reason": "Repeated violations"
}
```

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/moderation/users/1/ban \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Repeated violations"
  }'
```

---

### POST /api/moderation/users/{id}/suspend

Suspend a user (Admin only).

**Authentication:** Required (ADMIN role)

**Path Parameters:**
- `id` (required): User ID

**Request Body:**
```json
{
  "days": 7,
  "reason": "Temporary suspension"
}
```

**Field Validation:**
- `days` (required): Positive integer
- `reason` (required): String

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/moderation/users/1/suspend \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "days": 7,
    "reason": "Temporary suspension"
  }'
```

---

### POST /api/moderation/users/{id}/unban

Unban a user (Admin only).

**Authentication:** Required (ADMIN role)

**Path Parameters:**
- `id` (required): User ID

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/moderation/users/1/unban \
  -H "Authorization: Bearer $TOKEN"
```

---

## Admin Endpoints

All admin endpoints require ADMIN role.

### GET /api/admin/users

Get all users.

**Authentication:** Required (ADMIN role)

**Response:** `200 OK` (array of UserResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/admin/users \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/admin/users/{id}

Get user by ID.

**Authentication:** Required (ADMIN role)

**Path Parameters:**
- `id` (required): User ID

**Response:** `200 OK` (UserResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/admin/users/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### PUT /api/admin/users/{id}/enable

Enable or disable a user.

**Authentication:** Required (ADMIN role)

**Path Parameters:**
- `id` (required): User ID

**Request Body:**
```json
{
  "enabled": true
}
```

**Field Validation:**
- `enabled` (required): Boolean

**Response:** `200 OK` (UserResponse)

**cURL Example:**
```bash
curl -X PUT http://localhost:8080/api/admin/users/1/enable \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "enabled": true
  }'
```

---

### GET /api/admin/rides

Get all rides.

**Authentication:** Required (ADMIN role)

**Response:** `200 OK` (array of RideResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/admin/rides \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/admin/rides/{id}

Get ride by ID.

**Authentication:** Required (ADMIN role)

**Path Parameters:**
- `id` (required): Ride ID

**Response:** `200 OK` (RideResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/admin/rides/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### PUT /api/admin/rides/{id}/complete

Force complete a ride.

**Authentication:** Required (ADMIN role)

**Path Parameters:**
- `id` (required): Ride ID

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X PUT http://localhost:8080/api/admin/rides/1/complete \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/admin/bookings

Get all bookings.

**Authentication:** Required (ADMIN role)

**Response:** `200 OK` (array of BookingResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/admin/bookings \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/admin/bookings/{id}

Get booking by ID.

**Authentication:** Required (ADMIN role)

**Path Parameters:**
- `id` (required): Booking ID

**Response:** `200 OK` (BookingResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/admin/bookings/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/admin/payments

Get all payments.

**Authentication:** Required (ADMIN role)

**Response:** `200 OK` (array of PaymentResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/admin/payments \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/admin/payments/{id}

Get payment by ID.

**Authentication:** Required (ADMIN role)

**Path Parameters:**
- `id` (required): Payment ID

**Response:** `200 OK` (PaymentResponse)

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/admin/payments/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/admin/database/reset

Reset the entire database by deleting all data (Admin only).

**Authentication:** Required (ADMIN role)

**Warning:** This operation is irreversible and will delete all data from the database including:
- All users (except the default admin account will be recreated on next startup)
- All rides, bookings, payments, ratings, notifications
- All locations, vehicles, GPS tracking data

**Note:** This only deletes data. The database schema remains unchanged. Use `/api/admin/database/regenerate` to drop and recreate the schema.

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/admin/database/reset \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/admin/database/regenerate

Regenerate the database schema by dropping all tables and letting Hibernate recreate them (Admin only).

**Authentication:** Required (ADMIN role)

**Warning:** This operation is irreversible and will:
- Drop all database tables, sequences, and constraints
- Delete all data in the database
- Recreate the schema from scratch based on current entity definitions
- The default admin account will be recreated on next operation

**Use Case:** Use this endpoint when you have changed the database schema (e.g., added/removed columns, changed field types) and want to regenerate the database with the new schema structure. This is different from `/api/admin/database/reset` which only deletes data but keeps the old schema.

**Response:** `200 OK` (empty body)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/admin/database/regenerate \
  -H "Authorization: Bearer $TOKEN"
```

**Note:** After regeneration, the database schema will match the current entity definitions. Hibernate will automatically recreate all tables based on `ddl-auto=update` setting.

---

## Permissions Matrix

| Endpoint | Public | Authenticated | Driver | Rider | Admin |
|----------|--------|----------------|--------|-------|-------|
| POST /api/auth/register | ✅ | - | - | - | - |
| POST /api/auth/login | ✅ | - | - | - | - |
| GET /api/health | ✅ | - | - | - | - |
| GET /api/users/me | - | ✅ | ✅ | ✅ | ✅ |
| PUT /api/users/me | - | ✅ | ✅ | ✅ | ✅ |
| POST /api/vehicles | - | - | ✅ | - | ✅ |
| GET /api/vehicles/me | - | ✅ | ✅ | ✅ | ✅ |
| POST /api/rides | - | - | ✅ | - | ✅ |
| GET /api/rides/search | - | ✅ | ✅ | ✅ | ✅ |
| POST /api/bookings | - | - | - | ✅ | ✅ |
| POST /api/payments/initiate | - | ✅ | ✅ | ✅ | ✅ |
| POST /api/ratings | - | ✅ | ✅ | ✅ | ✅ |
| GET /api/analytics/driver/earnings | - | - | ✅ | - | ✅ |
| GET /api/analytics/rider/spending | - | - | - | ✅ | ✅ |
| GET /api/admin/* | - | - | - | - | ✅ |
| GET /api/moderation/reports | - | - | - | - | ✅ |
| POST /api/moderation/report | - | ✅ | ✅ | ✅ | ✅ |

**Notes:**
- "Authenticated" means any logged-in user
- "Driver" means DRIVER or BOTH role
- "Rider" means RIDER or BOTH role
- "Admin" means ADMIN role only

---

## Data Models

### UserResponse

```json
{
  "id": 1,
  "universityId": "S123456",
  "email": "user@university.edu",
  "fullName": "John Doe",
  "phoneNumber": "+1234567890",
  "role": "RIDER",
  "enabled": true,
  "createdAt": "2024-01-15T10:30:00",
  "walletBalance": 0.00,
  "avgRatingAsDriver": 4.5,
  "ratingCountAsDriver": 10,
  "avgRatingAsRider": 4.8,
  "ratingCountAsRider": 25
}
```

### VehicleResponse

```json
{
  "id": 1,
  "ownerId": 1,
  "make": "Toyota",
  "model": "Camry",
  "color": "Blue",
  "plateNumber": "ABC-1234",
  "seatCount": 4,
  "createdAt": "2024-01-15T10:30:00"
}
```

### LocationResponse

```json
{
  "id": 1,
  "userId": 1,
  "label": "Home",
  "address": "123 Main St",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "isFavorite": true,
  "createdAt": "2024-01-15T10:30:00"
}
```

### RideResponse

```json
{
  "id": 1,
  "driverId": 1,
  "driverName": "John Doe",
  "vehicleId": 1,
  "pickupLocation": { ... },
  "destinationLocation": { ... },
  "departureTimeStart": "2024-12-15T14:30:00",
  "departureTimeEnd": "2024-12-15T14:45:00",
  "totalSeats": 4,
  "availableSeats": 2,
  "basePrice": 10.00,
  "pricePerSeat": 5.00,
  "status": "SCHEDULED",
  "distanceKm": 5.2,
  "estimatedDurationMinutes": 15,
  "createdAt": "2024-01-15T10:30:00"
}
```

### BookingResponse

```json
{
  "bookingId": 1,
  "rideId": 1,
  "passengerId": 1,
  "passengerName": "Jane Doe",
  "seatsBooked": 2,
  "pickupLocationId": 1,
  "pickupLocationLabel": "University Main Gate",
  "pickupLatitude": 26.3192576,
  "pickupLongitude": 50.62656,
  "dropoffLocationId": 2,
  "dropoffLocationLabel": "City Center",
  "dropoffLatitude": 26.31998846367632,
  "dropoffLongitude": 50.63316896301268,
  "pickupTimeStart": "2024-12-15T14:30:00Z",
  "pickupTimeEnd": "2024-12-15T14:45:00Z",
  "createdAt": "2024-01-15T10:30:00Z",
  "status": "CONFIRMED",
  "costForThisRider": 20.00,
  "cancelledAt": null
}
```

### PaymentResponse

```json
{
  "id": 1,
  "bookingId": 1,
  "payerId": 1,
  "payerName": "Jane Doe",
  "driverId": 2,
  "driverName": "John Doe",
  "amount": 20.00,
  "platformFee": 2.00,
  "driverEarnings": 18.00,
  "method": "WALLET",
  "status": "COMPLETED",
  "transactionRef": "TXN-123456",
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T10:30:00"
}
```

### RatingResponse

```json
{
  "id": 1,
  "fromUserId": 1,
  "fromUserName": "Jane Doe",
  "toUserId": 2,
  "toUserName": "John Doe",
  "bookingId": 1,
  "score": 5,
  "comment": "Great driver!",
  "createdAt": "2024-01-15T10:30:00"
}
```

### NotificationResponse

```json
{
  "id": 1,
  "userId": 1,
  "type": "BOOKING",
  "title": "New Booking",
  "body": "You have a new booking",
  "read": false,
  "createdAt": "2024-01-15T10:30:00"
}
```

---

## JWT Token Decoding

JWT tokens contain user information in the payload. You can decode them using online tools like [jwt.io](https://jwt.io) or programmatically.

### Token Structure

A JWT token consists of three parts separated by dots:
```
header.payload.signature
```

### Decoded Payload Example

```json
{
  "sub": "user@university.edu",
  "userId": 1,
  "role": "RIDER",
  "iat": 1705315200,
  "exp": 1705401600
}
```

**Fields:**
- `sub`: Subject (user email)
- `userId`: User ID
- `role`: User role
- `iat`: Issued at (timestamp)
- `exp`: Expiration (timestamp)

### Example: Decode Token in JavaScript

```javascript
function decodeJWT(token) {
  const base64Url = token.split('.')[1];
  const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
  const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
    return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
  }).join(''));
  return JSON.parse(jsonPayload);
}
```

---

## Pagination and Filtering

Currently, the API does not implement pagination for list endpoints. All list endpoints return all matching results. Pagination may be added in future versions.

### Filtering

Many endpoints support filtering through request body parameters:

**Example: Ride Search**
```json
{
  "pickupLocationId": 1,
  "destinationLocationId": 2,
  "departureTimeFrom": "2024-12-15T00:00:00",
  "departureTimeTo": "2024-12-15T23:59:59",
  "minAvailableSeats": 1,
  "maxPrice": 50.00,
  "sortBy": "price"
}
```

**Example: Analytics with Date Range**
```
GET /api/analytics/driver/earnings?from=2024-01-01&to=2024-12-31
```

### Sorting

Some endpoints support sorting:

- **Ride Search**: `sortBy` parameter accepts `distance`, `price`, or `departureTime`
- **Analytics**: Results are typically sorted by count or date

---

## Health Check

### GET /api/health

Public endpoint to check API health status.

**Authentication:** Not required

**Response:** `200 OK`
```json
{
  "status": "UP",
  "timestamp": "2024-01-15T10:30:00.123Z",
  "version": "0.0.1-SNAPSHOT"
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/health
```

---

**Last Updated:** 2024-12-15

