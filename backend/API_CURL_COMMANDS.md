# UniPool Backend API - cURL Commands Reference

Complete collection of cURL commands to test all REST API endpoints.

**Base URL:** `http://localhost:8080/api`

---

## Table of Contents

1. [Authentication](#authentication)
2. [Health Check](#health-check)
3. [User Management](#user-management)
4. [Vehicle Management](#vehicle-management)
5. [Ride Management](#ride-management)
6. [Booking Management](#booking-management)
7. [Rating Management](#rating-management)
8. [Payment Management](#payment-management)
9. [Location Management](#location-management)
10. [GPS Tracking](#gps-tracking)
11. [Notifications](#notifications)
12. [Analytics](#analytics)
13. [Admin Endpoints](#admin-endpoints)
14. [Complete User Flows](#complete-user-flows)

---

## Authentication

### Register New User

Register a new user account and receive JWT token.

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "universityId": "S123456",
    "email": "john.doe@university.edu",
    "password": "SecurePass123!",
    "fullName": "John Doe",
    "phoneNumber": "+1234567890",
    "role": "RIDER"
  }'
```

**Response:** Returns JWT token in `token` field. Save this token for authenticated requests.

**Role Options:** `RIDER`, `DRIVER`, `BOTH`, `ADMIN`

---

### Login

Authenticate existing user and receive JWT token.

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@university.edu",
    "password": "SecurePass123!"
  }'
```

**Response:** Returns JWT token in `token` field.

---

### Get Current User

Get authenticated user's profile information.

```bash
# Extract token from login/register response first
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (Bearer token)

---

## Health Check

### Check API Health

Public endpoint to verify API is running.

```bash
curl -X GET http://localhost:8080/api/health
```

**Response:**
```json
{
  "status": "UP",
  "timestamp": "2024-01-15T10:30:00.123Z",
  "version": "0.0.1-SNAPSHOT"
}
```

---

## User Management

### Get Current User Profile

```bash
curl -X GET http://localhost:8080/api/users/me \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get User by ID

```bash
curl -X GET http://localhost:8080/api/users/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Update Current User Profile

```bash
curl -X PUT http://localhost:8080/api/users/me \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "John Updated Doe",
    "phoneNumber": "+1234567891"
  }'
```

**Authentication:** Required

---

### Change Password

```bash
curl -X PUT http://localhost:8080/api/users/me/password \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "oldPassword": "SecurePass123!",
    "newPassword": "NewSecurePass456!"
  }'
```

**Authentication:** Required

---

### Update User Role

Change user role (RIDER, DRIVER, BOTH).

```bash
curl -X PUT http://localhost:8080/api/users/me/role \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "BOTH"
  }'
```

**Authentication:** Required

---

### Get User Settings

```bash
curl -X GET http://localhost:8080/api/users/me/settings \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Update User Settings

```bash
curl -X PUT http://localhost:8080/api/users/me/settings \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
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
  }'
```

**Authentication:** Required

---

### Get User Statistics

```bash
curl -X GET http://localhost:8080/api/users/me/stats \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

## Vehicle Management

### Create Vehicle

Register a new vehicle (requires DRIVER role).

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

**Authentication:** Required (DRIVER role)

---

### Get Vehicle by ID

```bash
curl -X GET http://localhost:8080/api/vehicles/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get My Vehicles

Get all vehicles owned by current user.

```bash
curl -X GET http://localhost:8080/api/vehicles/me \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get My Active Vehicles

Get only active vehicles owned by current user.

```bash
curl -X GET http://localhost:8080/api/vehicles/me/active \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Update Vehicle

```bash
curl -X PUT http://localhost:8080/api/vehicles/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "make": "Honda",
    "model": "Accord",
    "color": "Red",
    "plateNumber": "XYZ-5678",
    "seatCount": 5,
    "active": true
  }'
```

**Authentication:** Required (Vehicle owner)

---

### Activate Vehicle

```bash
curl -X PUT http://localhost:8080/api/vehicles/1/activate \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (Vehicle owner)

---

### Delete Vehicle

```bash
curl -X DELETE http://localhost:8080/api/vehicles/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (Vehicle owner)

---

## Ride Management

### Create Ride

Create a new ride (requires DRIVER role and vehicle).

```bash
curl -X POST http://localhost:8080/api/rides \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicleId": 1,
    "pickupLocationId": 1,
    "destinationLocationId": 2,
    "departureTime": "2024-12-15T14:30:00",
    "totalSeats": 4,
    "basePrice": 10.00,
    "pricePerSeat": 5.00
  }'
```

**Authentication:** Required (DRIVER role)

**Note:** `departureTime` must be in the future. Format: `YYYY-MM-DDTHH:mm:ss`

---

### Get Ride by ID

```bash
curl -X GET http://localhost:8080/api/rides/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Search Rides

Search for available rides with filters.

```bash
curl -X POST http://localhost:8080/api/rides/search \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "pickupLocationId": 1,
    "destinationLocationId": 2,
    "departureTimeFrom": "2024-12-15T00:00:00",
    "departureTimeTo": "2024-12-15T23:59:59",
    "minAvailableSeats": 2,
    "maxPrice": 50.00,
    "sortBy": "price"
  }'
```

**Alternative with coordinates:**

```bash
curl -X POST http://localhost:8080/api/rides/search \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "pickupLatitude": 40.7128,
    "pickupLongitude": -74.0060,
    "pickupRadiusKm": 5.0,
    "destinationLatitude": 40.7580,
    "destinationLongitude": -73.9855,
    "destinationRadiusKm": 5.0,
    "departureTimeFrom": "2024-12-15T00:00:00",
    "minAvailableSeats": 1,
    "sortBy": "distance"
  }'
```

**Authentication:** Required

**Sort Options:** `distance`, `price`, `departureTime`

---

### Get Rides by Driver

```bash
curl -X GET http://localhost:8080/api/rides/driver/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get My Rides as Driver

```bash
curl -X GET http://localhost:8080/api/rides/me/driver \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (DRIVER role)

---

### Update Ride

```bash
curl -X PUT http://localhost:8080/api/rides/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "pickupLocationId": 3,
    "destinationLocationId": 4,
    "departureTime": "2024-12-15T15:00:00",
    "totalSeats": 5,
    "basePrice": 12.00,
    "pricePerSeat": 6.00
  }'
```

**Authentication:** Required (Ride owner/Driver)

---

### Update Ride Status

```bash
curl -X PATCH http://localhost:8080/api/rides/1/status \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "IN_PROGRESS"
  }'
```

**Authentication:** Required (Ride owner/Driver)

**Status Options:** `SCHEDULED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`

---

### Cancel Ride

```bash
curl -X DELETE http://localhost:8080/api/rides/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (Ride owner/Driver)

---

### Get Available Seats

```bash
curl -X GET http://localhost:8080/api/rides/1/available-seats \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

## Booking Management

### Create Booking

Book a ride (requires RIDER role).

```bash
curl -X POST http://localhost:8080/api/bookings \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "rideId": 1,
    "seats": 2
  }'
```

**Authentication:** Required (RIDER role)

---

### Get Booking by ID

```bash
curl -X GET http://localhost:8080/api/bookings/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get My Bookings

Get all bookings for current user.

```bash
curl -X GET http://localhost:8080/api/bookings/me \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get Bookings for Rider

```bash
curl -X GET http://localhost:8080/api/bookings/rider/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get Bookings for Ride

Get all bookings for a specific ride (Driver only).

```bash
curl -X GET http://localhost:8080/api/bookings/ride/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (Ride owner/Driver)

---

### Cancel Booking

```bash
curl -X POST http://localhost:8080/api/bookings/1/cancel \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (Booking owner)

---

## Rating Management

### Create Rating

Rate a user after a completed booking.

```bash
curl -X POST http://localhost:8080/api/ratings \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bookingId": 1,
    "score": 5,
    "comment": "Great driver, very punctual!"
  }'
```

**Authentication:** Required

**Score Range:** 1-5

---

### Get Rating by ID

```bash
curl -X GET http://localhost:8080/api/ratings/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get Ratings for User

```bash
curl -X GET http://localhost:8080/api/ratings/user/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get Ratings Given by Me

```bash
curl -X GET http://localhost:8080/api/ratings/me/given \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get Rating for Booking

```bash
curl -X GET http://localhost:8080/api/ratings/booking/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

## Payment Management

### Initiate Payment

Start payment for a booking.

```bash
curl -X POST http://localhost:8080/api/payments/initiate \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bookingId": 1,
    "method": "WALLET"
  }'
```

**Authentication:** Required

**Payment Methods:** `CARD_SIMULATED`, `CASH`, `WALLET`

---

### Get Payment by ID

```bash
curl -X GET http://localhost:8080/api/payments/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get My Payments

```bash
curl -X GET http://localhost:8080/api/payments/me \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get My Driver Payments

Get payments received as driver.

```bash
curl -X GET http://localhost:8080/api/payments/me/driver \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (DRIVER role)

---

### Get Payments for User

```bash
curl -X GET http://localhost:8080/api/payments/user/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get Payments for Booking

```bash
curl -X GET http://localhost:8080/api/payments/booking/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Process Payment

Mark payment as processed (simulation).

```bash
curl -X POST http://localhost:8080/api/payments/1/process \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Refund Payment

```bash
curl -X POST http://localhost:8080/api/payments/1/refund \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get Wallet Balance

```bash
curl -X GET http://localhost:8080/api/payments/wallet/balance \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Top Up Wallet

Add funds to wallet.

```bash
curl -X POST http://localhost:8080/api/payments/wallet/topup \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100.00
  }'
```

**Authentication:** Required

---

## Location Management

### Create Location

Save a location (home, work, favorite places).

```bash
curl -X POST http://localhost:8080/api/locations \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "Home",
    "address": "123 Main St, City, State 12345",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "isFavorite": true
  }'
```

**Authentication:** Required

---

### Get Location by ID

```bash
curl -X GET http://localhost:8080/api/locations/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get My Locations

```bash
curl -X GET http://localhost:8080/api/locations/me \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get My Favorite Locations

```bash
curl -X GET http://localhost:8080/api/locations/me/favorites \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Update Location

```bash
curl -X PUT http://localhost:8080/api/locations/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "Updated Home",
    "address": "456 New St, City, State 12345",
    "latitude": 40.7130,
    "longitude": -74.0062,
    "isFavorite": true
  }'
```

**Authentication:** Required (Location owner)

---

### Delete Location

```bash
curl -X DELETE http://localhost:8080/api/locations/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (Location owner)

---

### Calculate Distance

Calculate distance between two locations.

```bash
curl -X POST http://localhost:8080/api/locations/distance \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "locationAId": 1,
    "locationBId": 2
  }'
```

**Authentication:** Required

---

### Search Location

Search for locations by query string.

```bash
curl -X POST http://localhost:8080/api/locations/search \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Times Square, New York"
  }'
```

**Authentication:** Required

---

### Reverse Geocode

Get address from coordinates.

```bash
curl -X GET "http://localhost:8080/api/locations/reverse-geocode?latitude=40.7128&longitude=-74.0060" \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

## GPS Tracking

### Start Tracking

Start GPS tracking for a ride (Driver only).

```bash
curl -X POST http://localhost:8080/api/tracking/1/start \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (Ride owner/Driver)

---

### Update Location

Update current GPS location during ride (Driver only).

```bash
curl -X POST http://localhost:8080/api/tracking/1/update \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 40.7128,
    "longitude": -74.0060
  }'
```

**Authentication:** Required (Ride owner/Driver)

---

### Get Current Location

Get current GPS location of active ride.

```bash
curl -X GET http://localhost:8080/api/tracking/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Stop Tracking

Stop GPS tracking for a ride (Driver only).

```bash
curl -X POST http://localhost:8080/api/tracking/1/stop \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (Ride owner/Driver)

---

## Notifications

### Get My Notifications

```bash
curl -X GET http://localhost:8080/api/notifications/me \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get Unread Notifications

```bash
curl -X GET http://localhost:8080/api/notifications/me/unread \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get Unread Count

```bash
curl -X GET http://localhost:8080/api/notifications/me/unread-count \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Mark Notification as Read

```bash
curl -X POST http://localhost:8080/api/notifications/1/read \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Mark All Notifications as Read

```bash
curl -X POST http://localhost:8080/api/notifications/me/read-all \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

## Analytics

### Get Driver Earnings

Get earnings statistics for driver.

```bash
# All time
curl -X GET http://localhost:8080/api/analytics/driver/earnings \
  -H "Authorization: Bearer $TOKEN"

# Date range
curl -X GET "http://localhost:8080/api/analytics/driver/earnings?from=2024-01-01&to=2024-12-31" \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (DRIVER role)

---

### Get Rider Spending

Get spending statistics for rider.

```bash
# All time
curl -X GET http://localhost:8080/api/analytics/rider/spending \
  -H "Authorization: Bearer $TOKEN"

# Date range
curl -X GET "http://localhost:8080/api/analytics/rider/spending?from=2024-01-01&to=2024-12-31" \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (RIDER role)

---

### Get Ride Statistics

```bash
curl -X GET http://localhost:8080/api/analytics/rides/stats \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required

---

### Get Booking Statistics (Admin)

```bash
curl -X GET http://localhost:8080/api/analytics/bookings/stats \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

### Get Popular Destinations (Admin)

```bash
# Default limit (10)
curl -X GET http://localhost:8080/api/analytics/destinations/popular \
  -H "Authorization: Bearer $TOKEN"

# Custom limit
curl -X GET "http://localhost:8080/api/analytics/destinations/popular?limit=20" \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

### Get Peak Times (Admin)

```bash
curl -X GET http://localhost:8080/api/analytics/times/peak \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

### Get Dashboard Statistics (Admin)

```bash
curl -X GET http://localhost:8080/api/analytics/dashboard \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

## Admin Endpoints

### Get All Users (Admin)

```bash
curl -X GET http://localhost:8080/api/admin/users \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

### Get User by ID (Admin)

```bash
curl -X GET http://localhost:8080/api/admin/users/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

### Enable/Disable User (Admin)

```bash
curl -X PUT http://localhost:8080/api/admin/users/1/enable \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "enabled": true
  }'
```

**Authentication:** Required (ADMIN role)

---

### Get All Rides (Admin)

```bash
curl -X GET http://localhost:8080/api/admin/rides \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

### Get Ride by ID (Admin)

```bash
curl -X GET http://localhost:8080/api/admin/rides/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

### Force Complete Ride (Admin)

```bash
curl -X PUT http://localhost:8080/api/admin/rides/1/complete \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

### Get All Bookings (Admin)

```bash
curl -X GET http://localhost:8080/api/admin/bookings \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

### Get Booking by ID (Admin)

```bash
curl -X GET http://localhost:8080/api/admin/bookings/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

### Get All Payments (Admin)

```bash
curl -X GET http://localhost:8080/api/admin/payments \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

### Get Payment by ID (Admin)

```bash
curl -X GET http://localhost:8080/api/admin/payments/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Authentication:** Required (ADMIN role)

---

## Complete User Flows

### Flow 1: Driver Creates Ride and Receives Booking

```bash
# 1. Register as Driver
DRIVER_TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "universityId": "D001",
    "email": "driver@university.edu",
    "password": "DriverPass123!",
    "fullName": "Driver Name",
    "role": "DRIVER"
  }' | jq -r '.token')

# 2. Create Vehicle
VEHICLE_ID=$(curl -s -X POST http://localhost:8080/api/vehicles \
  -H "Authorization: Bearer $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "make": "Toyota",
    "model": "Camry",
    "color": "Blue",
    "plateNumber": "DRV-001",
    "seatCount": 4
  }' | jq -r '.id')

# 3. Create Locations
PICKUP_LOCATION_ID=$(curl -s -X POST http://localhost:8080/api/locations \
  -H "Authorization: Bearer $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "University Main Gate",
    "address": "123 University Ave",
    "latitude": 40.7128,
    "longitude": -74.0060
  }' | jq -r '.id')

DEST_LOCATION_ID=$(curl -s -X POST http://localhost:8080/api/locations \
  -H "Authorization: Bearer $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "City Center",
    "address": "456 Main St",
    "latitude": 40.7580,
    "longitude": -73.9855
  }' | jq -r '.id')

# 4. Create Ride
RIDE_ID=$(curl -s -X POST http://localhost:8080/api/rides \
  -H "Authorization: Bearer $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"vehicleId\": $VEHICLE_ID,
    \"pickupLocationId\": $PICKUP_LOCATION_ID,
    \"destinationLocationId\": $DEST_LOCATION_ID,
    \"departureTime\": \"2024-12-15T14:30:00\",
    \"totalSeats\": 4,
    \"basePrice\": 10.00,
    \"pricePerSeat\": 5.00
  }" | jq -r '.id')

# 5. Register as Rider
RIDER_TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "universityId": "R001",
    "email": "rider@university.edu",
    "password": "RiderPass123!",
    "fullName": "Rider Name",
    "role": "RIDER"
  }' | jq -r '.token')

# 6. Top Up Wallet
curl -X POST http://localhost:8080/api/payments/wallet/topup \
  -H "Authorization: Bearer $RIDER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"amount": 100.00}'

# 7. Book Ride
BOOKING_ID=$(curl -s -X POST http://localhost:8080/api/bookings \
  -H "Authorization: Bearer $RIDER_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"rideId\": $RIDE_ID,
    \"seats\": 2
  }" | jq -r '.id')

# 8. Initiate Payment
curl -X POST http://localhost:8080/api/payments/initiate \
  -H "Authorization: Bearer $RIDER_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"bookingId\": $BOOKING_ID,
    \"method\": \"WALLET\"
  }"

# 9. Driver starts tracking
curl -X POST http://localhost:8080/api/tracking/$RIDE_ID/start \
  -H "Authorization: Bearer $DRIVER_TOKEN"

# 10. Driver updates location
curl -X POST http://localhost:8080/api/tracking/$RIDE_ID/update \
  -H "Authorization: Bearer $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 40.7130,
    "longitude": -74.0062
  }'

# 11. Driver updates ride status to IN_PROGRESS
curl -X PATCH http://localhost:8080/api/rides/$RIDE_ID/status \
  -H "Authorization: Bearer $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "IN_PROGRESS"}'

# 12. Driver completes ride
curl -X PATCH http://localhost:8080/api/rides/$RIDE_ID/status \
  -H "Authorization: Bearer $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "COMPLETED"}'

# 13. Rider rates driver
curl -X POST http://localhost:8080/api/ratings \
  -H "Authorization: Bearer $RIDER_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"bookingId\": $BOOKING_ID,
    \"score\": 5,
    \"comment\": \"Great ride!\"
  }"
```

---

### Flow 2: Rider Searches and Books Ride

```bash
# 1. Login as Rider
RIDER_TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "rider@university.edu",
    "password": "RiderPass123!"
  }' | jq -r '.token')

# 2. Create favorite locations
HOME_LOCATION_ID=$(curl -s -X POST http://localhost:8080/api/locations \
  -H "Authorization: Bearer $RIDER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "Home",
    "address": "789 Home St",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "isFavorite": true
  }' | jq -r '.id')

WORK_LOCATION_ID=$(curl -s -X POST http://localhost:8080/api/locations \
  -H "Authorization: Bearer $RIDER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "Work",
    "address": "321 Office Blvd",
    "latitude": 40.7580,
    "longitude": -73.9855,
    "isFavorite": true
  }' | jq -r '.id')

# 3. Search for rides
curl -X POST http://localhost:8080/api/rides/search \
  -H "Authorization: Bearer $RIDER_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"pickupLocationId\": $HOME_LOCATION_ID,
    \"destinationLocationId\": $WORK_LOCATION_ID,
    \"departureTimeFrom\": \"2024-12-15T08:00:00\",
    \"departureTimeTo\": \"2024-12-15T10:00:00\",
    \"minAvailableSeats\": 1,
    \"sortBy\": \"departureTime\"
  }"

# 4. Book a ride (assuming RIDE_ID from search results)
curl -X POST http://localhost:8080/api/bookings \
  -H "Authorization: Bearer $RIDER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "rideId": 1,
    "seats": 1
  }'

# 5. View my bookings
curl -X GET http://localhost:8080/api/bookings/me \
  -H "Authorization: Bearer $RIDER_TOKEN"

# 6. Check wallet balance
curl -X GET http://localhost:8080/api/payments/wallet/balance \
  -H "Authorization: Bearer $RIDER_TOKEN"
```

---

### Flow 3: Driver Manages Vehicles and Rides

```bash
# 1. Login as Driver
DRIVER_TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "driver@university.edu",
    "password": "DriverPass123!"
  }' | jq -r '.token')

# 2. View my vehicles
curl -X GET http://localhost:8080/api/vehicles/me \
  -H "Authorization: Bearer $DRIVER_TOKEN"

# 3. View active vehicles
curl -X GET http://localhost:8080/api/vehicles/me/active \
  -H "Authorization: Bearer $DRIVER_TOKEN"

# 4. View my rides as driver
curl -X GET http://localhost:8080/api/rides/me/driver \
  -H "Authorization: Bearer $DRIVER_TOKEN"

# 5. View bookings for a specific ride
curl -X GET http://localhost:8080/api/bookings/ride/1 \
  -H "Authorization: Bearer $DRIVER_TOKEN"

# 6. View driver earnings
curl -X GET http://localhost:8080/api/analytics/driver/earnings \
  -H "Authorization: Bearer $DRIVER_TOKEN"

# 7. View driver payments
curl -X GET http://localhost:8080/api/payments/me/driver \
  -H "Authorization: Bearer $DRIVER_TOKEN"
```

---

### Flow 4: User Manages Profile and Settings

```bash
# 1. Login
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@university.edu",
    "password": "Password123!"
  }' | jq -r '.token')

# 2. Get current user profile
curl -X GET http://localhost:8080/api/users/me \
  -H "Authorization: Bearer $TOKEN"

# 3. Update profile
curl -X PUT http://localhost:8080/api/users/me \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Updated Name",
    "phoneNumber": "+1234567890"
  }'

# 4. Get settings
curl -X GET http://localhost:8080/api/users/me/settings \
  -H "Authorization: Bearer $TOKEN"

# 5. Update settings
curl -X PUT http://localhost:8080/api/users/me/settings \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "emailNotifications": true,
    "pushNotifications": true,
    "allowSmoking": false,
    "allowPets": true,
    "preferredPaymentMethod": "WALLET"
  }'

# 6. Get user statistics
curl -X GET http://localhost:8080/api/users/me/stats \
  -H "Authorization: Bearer $TOKEN"

# 7. Change password
curl -X PUT http://localhost:8080/api/users/me/password \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "oldPassword": "Password123!",
    "newPassword": "NewPassword456!"
  }'
```

---

### Flow 5: Notifications and Location Management

```bash
# 1. Login
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@university.edu",
    "password": "Password123!"
  }' | jq -r '.token')

# 2. Get unread notification count
curl -X GET http://localhost:8080/api/notifications/me/unread-count \
  -H "Authorization: Bearer $TOKEN"

# 3. Get unread notifications
curl -X GET http://localhost:8080/api/notifications/me/unread \
  -H "Authorization: Bearer $TOKEN"

# 4. Mark notification as read
curl -X POST http://localhost:8080/api/notifications/1/read \
  -H "Authorization: Bearer $TOKEN"

# 5. Get all notifications
curl -X GET http://localhost:8080/api/notifications/me \
  -H "Authorization: Bearer $TOKEN"

# 6. Create location
curl -X POST http://localhost:8080/api/locations \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "Coffee Shop",
    "address": "123 Coffee St",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "isFavorite": false
  }'

# 7. Get my locations
curl -X GET http://localhost:8080/api/locations/me \
  -H "Authorization: Bearer $TOKEN"

# 8. Get favorite locations
curl -X GET http://localhost:8080/api/locations/me/favorites \
  -H "Authorization: Bearer $TOKEN"

# 9. Search for location
curl -X POST http://localhost:8080/api/locations/search \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Central Park"
  }'
```

---

## Notes

### Extracting JWT Token

After login or register, extract the token:

```bash
# Using jq (recommended)
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@university.edu", "password": "Password123!"}' \
  | jq -r '.token')

# Using grep and sed (if jq not available)
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@university.edu", "password": "Password123!"}' \
  | grep -o '"token":"[^"]*' | sed 's/"token":"//')
```

### Authentication Header Format

All protected endpoints require:
```
Authorization: Bearer <TOKEN>
```

### Date/Time Format

Use ISO 8601 format: `YYYY-MM-DDTHH:mm:ss`
Example: `2024-12-15T14:30:00`

### Payment Methods

- `CARD_SIMULATED` - Simulated card payment
- `CASH` - Cash payment
- `WALLET` - Wallet balance payment

### Ride Status Values

- `SCHEDULED` - Ride is scheduled
- `IN_PROGRESS` - Ride is currently happening
- `COMPLETED` - Ride completed
- `CANCELLED` - Ride cancelled

### User Roles

- `RIDER` - Can book rides
- `DRIVER` - Can create rides and vehicles
- `BOTH` - Can do both rider and driver actions
- `ADMIN` - Administrative access

---

## Troubleshooting

### 401 Unauthorized
- Token expired or invalid
- Missing Authorization header
- Token not in Bearer format

### 403 Forbidden
- User doesn't have required role
- User trying to access another user's resource

### 400 Bad Request
- Validation errors (check request body format)
- Missing required fields
- Invalid date/time format
- Invalid enum values

### 404 Not Found
- Resource doesn't exist
- Invalid ID in URL path

---

**Last Updated:** 2024-12-02

