# UniPool REST API Documentation

## Table of Contents

- [Base URL and Authentication](#base-url-and-authentication)
- [Authentication Guide](#authentication-guide)
- [Health Check](#health-check)
- [Authentication Endpoints](#authentication-endpoints)
- [User Management](#user-management)
- [Vehicle Management](#vehicle-management)
- [Location Management](#location-management)
- [Ride Management](#ride-management)
- [GPS Tracking](#gps-tracking)
- [Booking Management](#booking-management)
- [Payment Management](#payment-management)
- [Rating System](#rating-system)
- [Notifications](#notifications)
- [Analytics](#analytics)
- [Admin Endpoints](#admin-endpoints)
- [Data Models](#data-models)
- [Status Codes and Errors](#status-codes-and-errors)
- [Frontend Integration Guide](#frontend-integration-guide)

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

---

## Authentication Guide

### Registration

To register a new user, send a POST request to `/api/auth/register` with user details.

**Response:** Returns a JWT token and user information. Store the token securely.

### Login

To authenticate, send a POST request to `/api/auth/login` with email and password.

**Response:** Returns a JWT token and user information.

### Using the Token

1. Store the token securely (e.g., in localStorage, secure storage, or memory)
2. Include it in every protected request:
   ```
   Authorization: Bearer <token>
   ```
3. Token expires after 24 hours (86400000 milliseconds)
4. If you receive a 401 Unauthorized response, the token may be expired or invalid

### Error Cases

- **401 Unauthorized:** Invalid credentials or expired token
- **400 Bad Request:** Validation errors (missing fields, invalid email format, etc.)
- **409 Conflict:** Email or university ID already exists (during registration)

---

## Health Check

### GET /api/health

Public endpoint to check API health status.

**Authentication:** Not required

**Response:**
```json
{
  "status": "UP",
  "timestamp": "2024-01-15T10:30:00.123Z",
  "version": "0.0.1-SNAPSHOT"
}
```

**Status Codes:**
- `200 OK` - Service is healthy

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
  "password": "securePassword123",
  "fullName": "John Doe",
  "phoneNumber": "1234567890",
  "role": "RIDER"
}
```

**Field Descriptions:**
- `universityId` (required): Unique university student ID
- `email` (required): Valid email address
- `password` (required): User password
- `fullName` (required): User's full name
- `phoneNumber` (optional): Phone number
- `role` (optional): User role - `RIDER`, `DRIVER`, or `BOTH` (default: `RIDER`)
  - **Note:** `ADMIN` role cannot be assigned during registration. Admin accounts must be created by existing administrators or through system initialization.

**Response:** `201 Created`
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "universityId": "S123456",
    "email": "user@university.edu",
    "fullName": "John Doe",
    "phoneNumber": "1234567890",
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

**Status Codes:**
- `201 Created` - Registration successful
- `400 Bad Request` - Validation errors, duplicate email/university ID, or attempting to register as ADMIN

---

### POST /api/auth/login

Authenticate user and receive JWT token.

**Authentication:** Not required

**Request Body:**
```json
{
  "email": "user@university.edu",
  "password": "securePassword123"
}
```

**Field Descriptions:**
- `email` (required): Valid email address
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
    "phoneNumber": "1234567890",
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

**Status Codes:**
- `200 OK` - Login successful
- `401 Unauthorized` - Invalid credentials
- `400 Bad Request` - Validation errors

---

### GET /api/auth/me

Get current authenticated user information.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "id": 1,
  "universityId": "S123456",
  "email": "user@university.edu",
  "fullName": "John Doe",
  "phoneNumber": "1234567890",
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

**Status Codes:**
- `200 OK` - Success
- `401 Unauthorized` - Not authenticated

---

## User Management

### GET /api/users/me

Get current user's profile.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "id": 1,
  "universityId": "S123456",
  "email": "user@university.edu",
  "fullName": "John Doe",
  "phoneNumber": "1234567890",
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

---

### GET /api/users/{id}

Get user profile by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): User ID

**Response:** `200 OK`
```json
{
  "id": 1,
  "universityId": "S123456",
  "email": "user@university.edu",
  "fullName": "John Doe",
  "phoneNumber": "1234567890",
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

**Status Codes:**
- `200 OK` - Success
- `404 Not Found` - User not found

---

### PUT /api/users/me

Update current user's profile.

**Authentication:** Required

**Request Body:**
```json
{
  "fullName": "John Updated Doe",
  "phoneNumber": "9876543210"
}
```

**Field Descriptions:**
- `fullName` (required): User's full name
- `phoneNumber` (optional): Phone number

**Response:** `200 OK`
```json
{
  "id": 1,
  "universityId": "S123456",
  "email": "user@university.edu",
  "fullName": "John Updated Doe",
  "phoneNumber": "9876543210",
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

---

### PUT /api/users/me/password

Change user password.

**Authentication:** Required

**Request Body:**
```json
{
  "oldPassword": "oldPassword123",
  "newPassword": "newPassword456"
}
```

**Field Descriptions:**
- `oldPassword` (required): Current password
- `newPassword` (required): New password

**Response:** `200 OK` (empty body)

**Status Codes:**
- `200 OK` - Password changed successfully
- `400 Bad Request` - Invalid current password or validation errors

---

### PUT /api/users/me/role

Update user role.

**Authentication:** Required

**Request Body:**
```json
{
  "role": "BOTH"
}
```

**Field Descriptions:**
- `role` (required): New role - `RIDER`, `DRIVER`, or `BOTH`
  - **Note:** `ADMIN` role cannot be assigned through this endpoint. Admin accounts must be created by existing administrators or through system initialization.

**Response:** `200 OK`
```json
{
  "id": 1,
  "universityId": "S123456",
  "email": "user@university.edu",
  "fullName": "John Doe",
  "phoneNumber": "1234567890",
  "role": "BOTH",
  "enabled": true,
  "createdAt": "2024-01-15T10:30:00",
  "walletBalance": 0.00,
  "avgRatingAsDriver": null,
  "ratingCountAsDriver": 0,
  "avgRatingAsRider": null,
  "ratingCountAsRider": 0
}
```

**Status Codes:**
- `200 OK` - Role updated successfully
- `403 Forbidden` - Invalid role value (including attempts to set ADMIN role)

---

### GET /api/users/me/settings

Get current user's settings.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "id": 1,
  "emailNotifications": true,
  "smsNotifications": false,
  "pushNotifications": true,
  "allowSmoking": false,
  "allowPets": false,
  "allowMusic": true,
  "preferQuietRides": false,
  "showPhoneNumber": true,
  "showEmail": false,
  "autoAcceptBookings": false,
  "preferredPaymentMethod": "WALLET"
}
```

---

### PUT /api/users/me/settings

Update user settings.

**Authentication:** Required

**Request Body:**
```json
{
  "emailNotifications": true,
  "smsNotifications": false,
  "pushNotifications": true,
  "allowSmoking": false,
  "allowPets": false,
  "allowMusic": true,
  "preferQuietRides": false,
  "showPhoneNumber": true,
  "showEmail": false,
  "autoAcceptBookings": false,
  "preferredPaymentMethod": "WALLET"
}
```

**Field Descriptions:** All fields are optional
- `emailNotifications`: Enable email notifications
- `smsNotifications`: Enable SMS notifications
- `pushNotifications`: Enable push notifications
- `allowSmoking`: Allow smoking in vehicle
- `allowPets`: Allow pets in vehicle
- `allowMusic`: Allow music in vehicle
- `preferQuietRides`: Prefer quiet rides
- `showPhoneNumber`: Show phone number to other users
- `showEmail`: Show email to other users
- `autoAcceptBookings`: Automatically accept booking requests (when enabled, bookings are immediately confirmed and seats are reserved)
- `preferredPaymentMethod`: Preferred payment method (`CARD_SIMULATED`, `CASH`, `WALLET`)

**Response:** `200 OK` (same structure as GET)

---

### GET /api/users/me/stats

Get current user's statistics.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "totalRidesAsDriver": 15,
  "totalBookingsAsRider": 32,
  "avgRatingAsDriver": 4.75,
  "ratingCountAsDriver": 12,
  "avgRatingAsRider": 4.50,
  "ratingCountAsRider": 28
}
```

---

### POST /api/users/me/upload-university-id

Upload university ID image for verification.

**Authentication:** Required

**Request Body:**
```json
{
  "imageData": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
}
```

**Field Descriptions:**
- `imageData` (required): Base64 encoded image data (can include data URI prefix)

**Response:** `200 OK` (UserResponse with updated universityIdImage)

**Status Codes:**
- `200 OK` - Image uploaded successfully
- `400 Bad Request` - Invalid image data

**Note:** After uploading, wait for admin verification. You cannot book rides until your university ID is verified.

---

### POST /api/users/me/upload-drivers-license

Upload driver's license image for verification.

**Authentication:** Required

**Request Body:**
```json
{
  "imageData": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
}
```

**Field Descriptions:**
- `imageData` (required): Base64 encoded image data (can include data URI prefix)

**Response:** `200 OK` (UserResponse with updated driversLicenseImage)

**Status Codes:**
- `200 OK` - Image uploaded successfully
- `400 Bad Request` - Invalid image data

**Note:** After uploading, wait for admin verification. You cannot post rides until you are verified as a driver.

---

## Vehicle Management

### POST /api/vehicles

Register a new vehicle.

**Authentication:** Required (Driver role)

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

**Field Descriptions:**
- `make` (required): Vehicle manufacturer
- `model` (required): Vehicle model
- `color` (optional): Vehicle color
- `plateNumber` (required): License plate number
- `seatCount` (required): Number of seats (must be positive)

**Response:** `201 Created`
```json
{
  "id": 1,
  "make": "Toyota",
  "model": "Camry",
  "color": "Blue",
  "plateNumber": "ABC-1234",
  "seatCount": 4,
  "ownerId": 1,
  "ownerName": "John Doe",
  "active": false,
  "createdAt": "2024-01-15T10:30:00"
}
```

---

### GET /api/vehicles/{id}

Get vehicle by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Vehicle ID

**Response:** `200 OK`
```json
{
  "id": 1,
  "make": "Toyota",
  "model": "Camry",
  "color": "Blue",
  "plateNumber": "ABC-1234",
  "seatCount": 4,
  "ownerId": 1,
  "ownerName": "John Doe",
  "active": false,
  "createdAt": "2024-01-15T10:30:00"
}
```

---

### GET /api/vehicles/me

Get all vehicles owned by current user.

**Authentication:** Required

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "make": "Toyota",
    "model": "Camry",
    "color": "Blue",
    "plateNumber": "ABC-1234",
    "seatCount": 4,
    "ownerId": 1,
    "ownerName": "John Doe",
    "active": true,
    "createdAt": "2024-01-15T10:30:00"
  }
]
```

---

### GET /api/vehicles/me/active

Get active vehicles owned by current user.

**Authentication:** Required

**Response:** `200 OK` (array of VehicleResponse)

---

### PUT /api/vehicles/{id}

Update vehicle information.

**Authentication:** Required (Owner only)

**Path Parameters:**
- `id` (required): Vehicle ID

**Request Body:**
```json
{
  "make": "Honda",
  "model": "Accord",
  "color": "Red",
  "plateNumber": "XYZ-5678",
  "seatCount": 5,
  "active": true
}
```

**Field Descriptions:** All fields are optional
- `make`: Vehicle manufacturer
- `model`: Vehicle model
- `color`: Vehicle color
- `plateNumber`: License plate number
- `seatCount`: Number of seats (must be positive if provided)
- `active`: Whether vehicle is active

**Response:** `200 OK` (VehicleResponse)

---

### PUT /api/vehicles/{id}/activate

Activate a vehicle.

**Authentication:** Required (Owner only)

**Path Parameters:**
- `id` (required): Vehicle ID

**Response:** `200 OK` (VehicleResponse)

---

### DELETE /api/vehicles/{id}

Delete a vehicle.

**Authentication:** Required (Owner only)

**Path Parameters:**
- `id` (required): Vehicle ID

**Response:** `200 OK` (empty body)

---

## Location Management

### POST /api/locations

Create a new location.

**Authentication:** Required

**Request Body:**
```json
{
  "label": "University Main Gate",
  "address": "123 University Ave",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "isFavorite": true
}
```

**Field Descriptions:**
- `label` (required): Location label/name
- `address` (optional): Full address
- `latitude` (required): Latitude coordinate
- `longitude` (required): Longitude coordinate
- `isFavorite` (optional): Mark as favorite

**Response:** `201 Created`
```json
{
  "id": 1,
  "label": "University Main Gate",
  "address": "123 University Ave",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "userId": 1,
  "isFavorite": true
}
```

---

### GET /api/locations/{id}

Get location by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Location ID

**Response:** `200 OK` (LocationResponse)

---

### GET /api/locations/me

Get all locations for current user.

**Authentication:** Required

**Response:** `200 OK` (array of LocationResponse)

---

### GET /api/locations/me/favorites

Get favorite locations for current user.

**Authentication:** Required

**Response:** `200 OK` (array of LocationResponse)

---

### PUT /api/locations/{id}

Update location.

**Authentication:** Required (Owner only)

**Path Parameters:**
- `id` (required): Location ID

**Request Body:**
```json
{
  "label": "Updated Location Name",
  "address": "456 New Street",
  "latitude": 40.7130,
  "longitude": -74.0062,
  "isFavorite": false
}
```

**Response:** `200 OK` (LocationResponse)

---

### DELETE /api/locations/{id}

Delete location.

**Authentication:** Required (Owner only)

**Path Parameters:**
- `id` (required): Location ID

**Response:** `200 OK` (empty body)

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

**Field Descriptions:**
- `locationAId` (required): First location ID
- `locationBId` (required): Second location ID

**Response:** `200 OK`
```json
{
  "distanceKm": 15.5,
  "estimatedDurationMinutes": 25
}
```

---

### POST /api/locations/search

Search for locations by query string.

**Authentication:** Required

**Request Body:**
```json
{
  "query": "University Main"
}
```

**Field Descriptions:**
- `query` (required): Search query string

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "label": "University Main Gate",
    "address": "123 University Ave",
    "latitude": 40.7128,
    "longitude": -74.0060
  }
]
```

---

### GET /api/locations/reverse-geocode

Reverse geocode coordinates to address.

**Authentication:** Required

**Query Parameters:**
- `latitude` (required): Latitude coordinate
- `longitude` (required): Longitude coordinate

**Example:** `/api/locations/reverse-geocode?latitude=40.7128&longitude=-74.0060`

**Response:** `200 OK`
```json
{
  "address": "123 University Ave, City, State 12345"
}
```

---

## Ride Management

### POST /api/rides

Create a new ride.

**Authentication:** Required (Driver role)

**Requirements:**
- User must be a **verified driver** (`verifiedDriver` must be `true`)
- Only admins can verify drivers after reviewing their driver's license image

**Request Body:**
```json
{
  "vehicleId": 1,
  "pickupLocationId": 1,
  "destinationLocationId": 2,
  "departureTimeStart": "2024-01-20T14:30:00Z",
  "departureTimeEnd": "2024-01-20T15:00:00Z",
  "totalSeats": 4,
  "basePrice": 10.00,
  "pricePerSeat": 5.00
}
```

**Field Descriptions:**
- `vehicleId` (required): Vehicle ID (must belong to the authenticated driver)
- `pickupLocationId` (required): Pickup location ID
- `destinationLocationId` (required): Destination location ID
- `departureTimeStart` (required): Start of departure time window (must be in the future)
- `departureTimeEnd` (required): End of departure time window (must be after departureTimeStart, max 24 hours)
  - **Note:** Cannot overlap with existing active rides. The system checks if the new ride's time window overlaps with any of the driver's existing active rides (excluding CANCELLED and COMPLETED rides).
- `totalSeats` (required): Total available seats (must be positive and cannot exceed vehicle capacity)
- `basePrice` (optional): Base price for the ride (defaults to 0.5 per km if not provided)
- `pricePerSeat` (optional): Price per seat (defaults to basePrice / totalSeats if not provided)

**Status Codes:**
- `201 Created` - Ride created successfully
- `400 Bad Request` - Validation errors, not a verified driver, or overlapping rides
- `403 Forbidden` - Not a verified driver

**Response:** `201 Created`
```json
{
  "id": 1,
  "driverId": 1,
  "driverName": "John Doe",
  "driverRating": 4.75,
  "vehicleId": 1,
  "vehicleMake": "Toyota",
  "vehicleModel": "Camry",
  "vehiclePlateNumber": "ABC-1234",
  "vehicleSeatCount": 4,
  "pickupLocationId": 1,
  "pickupLocationLabel": "University Main Gate",
  "pickupLatitude": 40.7128,
  "pickupLongitude": -74.0060,
  "destinationLocationId": 2,
  "destinationLocationLabel": "City Center",
  "destinationLatitude": 40.7580,
  "destinationLongitude": -73.9855,
  "departureTime": "2024-01-20T14:30:00",
  "totalSeats": 4,
  "availableSeats": 4,
  "estimatedDistanceKm": 15.5,
  "routeDistanceKm": 16.2,
  "estimatedDurationMinutes": 25,
  "basePrice": 10.00,
  "pricePerSeat": 5.00,
  "status": "POSTED",
  "createdAt": "2024-01-15T10:30:00",
  "routePolyline": "encoded_polyline_string"
}
```

**Status Codes:**
- `201 Created` - Ride created successfully
- `400 Bad Request` - Validation errors, invalid vehicle, or overlapping departure time
- `403 Forbidden` - Vehicle does not belong to the authenticated driver
- `404 Not Found` - Vehicle or location not found

**Error Cases:**
- **Overlapping Departure Time:** If the new ride's time window overlaps with an existing active ride, the request will be rejected with a 400 Bad Request error and message: "Cannot create ride with overlapping departure time. You have another active ride scheduled during this time period."
- **Invalid Vehicle:** Vehicle must belong to the authenticated driver and be active
- **Past Departure Time:** Departure time must be in the future
- **Exceeded Capacity:** Total seats cannot exceed the vehicle's seat count

---

### GET /api/rides/{id}

Get ride by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Ride ID

**Response:** `200 OK` (RideResponse)

---

### POST /api/rides/search

Search for rides matching criteria.

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
  "departureTimeFrom": "2024-01-20T00:00:00",
  "departureTimeTo": "2024-01-20T23:59:59",
  "minAvailableSeats": 2,
  "maxPrice": 50.00,
  "sortBy": "distance"
}
```

**Field Descriptions:** All fields are optional
- `pickupLocationId`: Pickup location ID
- `pickupLatitude`: Pickup latitude
- `pickupLongitude`: Pickup longitude
- `pickupRadiusKm`: Search radius from pickup (kilometers)
- `destinationLocationId`: Destination location ID
- `destinationLatitude`: Destination latitude
- `destinationLongitude`: Destination longitude
- `destinationRadiusKm`: Search radius from destination (kilometers)
- `departureTimeFrom`: Earliest departure time
- `departureTimeTo`: Latest departure time
- `minAvailableSeats`: Minimum available seats required
- `maxPrice`: Maximum price filter
- `sortBy`: Sort order - `distance`, `price`, or `departureTime`

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "driverId": 1,
    "driverName": "John Doe",
    "driverRating": 4.75,
    "vehicleId": 1,
    "vehicleMake": "Toyota",
    "vehicleModel": "Camry",
    "vehiclePlateNumber": "ABC-1234",
    "vehicleSeatCount": 4,
    "pickupLocationId": 1,
    "pickupLocationLabel": "University Main Gate",
    "pickupLatitude": 40.7128,
    "pickupLongitude": -74.0060,
    "destinationLocationId": 2,
    "destinationLocationLabel": "City Center",
    "destinationLatitude": 40.7580,
    "destinationLongitude": -73.9855,
    "departureTime": "2024-01-20T14:30:00",
    "totalSeats": 4,
    "availableSeats": 2,
    "estimatedDistanceKm": 15.5,
    "routeDistanceKm": 16.2,
    "estimatedDurationMinutes": 25,
    "basePrice": 10.00,
    "pricePerSeat": 5.00,
    "status": "POSTED",
    "createdAt": "2024-01-15T10:30:00",
    "routePolyline": "encoded_polyline_string"
  }
]
```

---

### GET /api/rides/driver/{driverId}

Get all rides by a specific driver.

**Authentication:** Required

**Path Parameters:**
- `driverId` (required): Driver user ID

**Response:** `200 OK` (array of RideResponse)

---

### GET /api/rides/me/driver

Get current user's rides as driver.

**Authentication:** Required

**Response:** `200 OK` (array of RideResponse)

---

### PUT /api/rides/{id}

Update ride information.

**Authentication:** Required (Driver/owner only)

**Path Parameters:**
- `id` (required): Ride ID

**Request Body:**
```json
{
  "pickupLocationId": 1,
  "destinationLocationId": 2,
  "departureTime": "2024-01-20T15:00:00",
  "totalSeats": 5,
  "basePrice": 12.00,
  "pricePerSeat": 6.00
}
```

**Field Descriptions:** All fields are optional
- `pickupLocationId`: Pickup location ID
- `destinationLocationId`: Destination location ID
- `departureTime`: Departure time (must be in the future if provided)
- `totalSeats`: Total seats (must be positive if provided)
- `basePrice`: Base price
- `pricePerSeat`: Price per seat

**Response:** `200 OK` (RideResponse)

---

### PATCH /api/rides/{id}/status

Update ride status.

**Authentication:** Required (Driver/owner only)

**Path Parameters:**
- `id` (required): Ride ID

**Request Body:**
```json
{
  "status": "IN_PROGRESS"
}
```

**Field Descriptions:**
- `status` (required): New status - `POSTED`, `IN_PROGRESS`, `COMPLETED`, or `CANCELLED`

**Response:** `200 OK` (RideResponse)

---

### DELETE /api/rides/{id}

Cancel a ride.

**Authentication:** Required (Driver/owner only)

**Path Parameters:**
- `id` (required): Ride ID

**Response:** `200 OK` (empty body)

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

---

## GPS Tracking

### POST /api/tracking/{rideId}/update

Update GPS location for an active ride.

**Authentication:** Required (Driver only)

**Path Parameters:**
- `rideId` (required): Ride ID

**Request Body:**
```json
{
  "latitude": 40.7128,
  "longitude": -74.0060
}
```

**Field Descriptions:**
- `latitude` (required): Current latitude
- `longitude` (required): Current longitude

**Response:** `200 OK` (empty body)

**Status Codes:**
- `200 OK` - Location updated
- `403 Forbidden` - Only driver can update location
- `404 Not Found` - Ride not found

---

### GET /api/tracking/{rideId}

Get current GPS location for a ride.

**Authentication:** Required

**Path Parameters:**
- `rideId` (required): Ride ID

**Response:** `200 OK`
```json
{
  "rideId": 1,
  "latitude": 40.7128,
  "longitude": -74.0060,
  "lastUpdate": "2024-01-20T14:35:00",
  "isActive": true
}
```

---

### POST /api/tracking/{rideId}/start

Start GPS tracking for a ride.

**Authentication:** Required (Driver only)

**Path Parameters:**
- `rideId` (required): Ride ID

**Response:** `200 OK` (empty body)

**Status Codes:**
- `200 OK` - Tracking started
- `403 Forbidden` - Only driver can start tracking
- `404 Not Found` - Ride not found

---

### POST /api/tracking/{rideId}/stop

Stop GPS tracking for a ride.

**Authentication:** Required (Driver only)

**Path Parameters:**
- `rideId` (required): Ride ID

**Response:** `200 OK` (empty body)

**Status Codes:**
- `200 OK` - Tracking stopped
- `403 Forbidden` - Only driver can stop tracking
- `404 Not Found` - Ride not found

---

## Booking Management

### POST /api/bookings

Create a new booking for a ride.

**Authentication:** Required (Rider role)

**Requirements:**
- User must have a **verified university ID** (`universityIdVerified` must be `true`)
- Only admins can verify university IDs after reviewing the university ID image

**Request Body:**
```json
{
  "rideId": 1,
  "seats": 2,
  "pickupLocationId": 3,
  "dropoffLocationId": 4,
  "pickupTimeStart": "2024-01-20T14:30:00Z",
  "pickupTimeEnd": "2024-01-20T15:00:00Z"
}
```

**Field Descriptions:**
- `rideId` (required): Ride ID to book
- `seats` (required): Number of seats to book (must be positive, cannot exceed ride capacity)
- `pickupLocationId` (required): Pickup location ID
- `dropoffLocationId` (required): Dropoff location ID
- `pickupTimeStart` (required): Start of pickup time window (must be in the future, within ride's departure time range)
- `pickupTimeEnd` (required): End of pickup time window (must be after pickupTimeStart, within ride's departure time range, and not more than 2 hours after pickupTimeStart)

**Booking Status:**
- Bookings are created with `PENDING` status by default
- If the driver has `autoAcceptBookings` enabled in their settings, the booking will be automatically confirmed (`CONFIRMED`) and seats will be reserved immediately
- Otherwise, the booking remains `PENDING` until the driver confirms or cancels it
- Seats are only reserved when a booking is confirmed

**Response:** `201 Created` (RideResponse with updated bookings)

**Status Codes:**
- `201 Created` - Booking created (pending or confirmed based on driver's auto-accept setting)
- `400 Bad Request` - Not enough available seats, validation errors, invalid time ranges, or university ID not verified
- `403 Forbidden` - Driver cannot book their own ride, or university ID not verified
- `404 Not Found` - Ride or location not found

---

### GET /api/bookings/{id}

Get booking by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Booking ID

**Response:** `200 OK` (BookingResponse)

---

### GET /api/bookings/me

Get current user's bookings.

**Authentication:** Required

**Response:** `200 OK` (array of BookingResponse)

---

### GET /api/bookings/rider/{riderId}

Get all bookings for a specific rider.

**Authentication:** Required

**Path Parameters:**
- `riderId` (required): Rider user ID

**Response:** `200 OK` (array of BookingResponse)

---

### GET /api/bookings/ride/{rideId}

Get all bookings for a specific ride (driver only).

**Authentication:** Required (Driver/owner only)

**Path Parameters:**
- `rideId` (required): Ride ID

**Response:** `200 OK` (array of BookingResponse)

---

### PUT /api/bookings/{bookingId}/status

Update booking status (Driver only).

Allows drivers to confirm or cancel pending bookings for their rides.

**Authentication:** Required (Driver role - must be the driver of the ride)

**Path Parameters:**
- `bookingId` (required): Booking ID

**Request Body:**
```json
{
  "status": "CONFIRMED"
}
```

**Field Descriptions:**
- `status` (required): New booking status - must be `CONFIRMED` or `CANCELLED`

**Status Transition Rules:**
- Can only update bookings with `PENDING` status
- When confirming: Seats are reserved if available. If not enough seats are available, the request will fail.
- When cancelling: Seats are not returned (they were never reserved for pending bookings)

**Response:** `200 OK` (BookingResponse)
```json
{
  "bookingId": 1,
  "rideId": 1,
  "passengerId": 2,
  "passengerName": "Jane Rider",
  "seatsBooked": 2,
  "pickupLocationId": 3,
  "pickupLocationLabel": "University Main Gate",
  "pickupLatitude": 40.7128,
  "pickupLongitude": -74.0060,
  "dropoffLocationId": 4,
  "dropoffLocationLabel": "City Center",
  "dropoffLatitude": 40.7580,
  "dropoffLongitude": -73.9855,
  "pickupTimeStart": "2024-01-20T14:30:00Z",
  "pickupTimeEnd": "2024-01-20T15:00:00Z",
  "createdAt": "2024-01-15T10:30:00Z",
  "status": "CONFIRMED",
  "costForThisRider": 20.00,
  "cancelledAt": null
}
```

**Status Codes:**
- `200 OK` - Booking status updated successfully
- `400 Bad Request` - Invalid status transition, not enough available seats (for confirmation), or validation errors
- `403 Forbidden` - Only the driver of the ride can update booking status
- `404 Not Found` - Booking not found

---

### POST /api/bookings/{bookingId}/cancel

Cancel a booking.

**Authentication:** Required (Rider or Driver)

**Path Parameters:**
- `bookingId` (required): Booking ID

**Notes:**
- Riders can cancel their own bookings
- Drivers can cancel bookings on their rides
- Seats are only returned to the ride if the booking was previously `CONFIRMED`
- Pending bookings can be cancelled without affecting seat availability

**Response:** `200 OK` (empty body)

**Status Codes:**
- `200 OK` - Booking cancelled
- `400 Bad Request` - Booking is already cancelled or completed
- `403 Forbidden` - Not authorized to cancel this booking
- `404 Not Found` - Booking not found

---

## Payment Management

### POST /api/payments/initiate

Initiate a payment for a booking.

**Authentication:** Required

**Request Body:**
```json
{
  "bookingId": 1,
  "method": "WALLET"
}
```

**Field Descriptions:**
- `bookingId` (required): Booking ID
- `method` (required): Payment method - `CARD_SIMULATED`, `CASH`, or `WALLET`

**Response:** `201 Created`
```json
{
  "id": 1,
  "bookingId": 1,
  "payerId": 2,
  "payerName": "Jane Rider",
  "driverId": 1,
  "driverName": "John Doe",
  "amount": 20.00,
  "platformFee": 2.00,
  "driverEarnings": 18.00,
  "method": "WALLET",
  "status": "INITIATED",
  "transactionRef": "TXN-123456",
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T10:30:00"
}
```

---

### GET /api/payments/{id}

Get payment by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Payment ID

**Response:** `200 OK` (PaymentResponse)

---

### GET /api/payments/me

Get current user's payments.

**Authentication:** Required

**Response:** `200 OK` (array of PaymentResponse)

---

### GET /api/payments/me/driver

Get current user's payments as driver.

**Authentication:** Required

**Response:** `200 OK` (array of PaymentResponse)

---

### GET /api/payments/user/{userId}

Get all payments for a specific user.

**Authentication:** Required

**Path Parameters:**
- `userId` (required): User ID

**Response:** `200 OK` (array of PaymentResponse)

---

### GET /api/payments/booking/{bookingId}

Get all payments for a specific booking.

**Authentication:** Required

**Path Parameters:**
- `bookingId` (required): Booking ID

**Response:** `200 OK` (array of PaymentResponse)

---

### POST /api/payments/{id}/process

Process a payment (admin or system).

**Authentication:** Required

**Path Parameters:**
- `id` (required): Payment ID

**Response:** `200 OK` (PaymentResponse with updated status)

---

### POST /api/payments/{id}/refund

Refund a payment.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Payment ID

**Response:** `200 OK` (PaymentResponse with status `REFUNDED`)

---

### GET /api/payments/wallet/balance

Get current user's wallet balance.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "balance": 50.00
}
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

**Field Descriptions:**
- `amount` (required): Amount to add (must be positive)

**Response:** `200 OK` (PaymentResponse)

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

**Field Descriptions:**
- `bookingId` (required): Booking ID
- `score` (required): Rating score (1-5)
- `comment` (optional): Rating comment

**Response:** `201 Created`
```json
{
  "id": 1,
  "fromUserId": 2,
  "fromUserName": "Jane Rider",
  "toUserId": 1,
  "toUserName": "John Doe",
  "bookingId": 1,
  "score": 5,
  "comment": "Great driver, very punctual!",
  "createdAt": "2024-01-15T10:30:00"
}
```

---

### GET /api/ratings/{id}

Get rating by ID.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Rating ID

**Response:** `200 OK` (RatingResponse)

---

### GET /api/ratings/user/{userId}

Get all ratings for a specific user.

**Authentication:** Required

**Path Parameters:**
- `userId` (required): User ID

**Response:** `200 OK` (array of RatingResponse)

---

### GET /api/ratings/me/given

Get ratings given by current user.

**Authentication:** Required

**Response:** `200 OK` (array of RatingResponse)

---

### GET /api/ratings/booking/{bookingId}

Get rating for a specific booking.

**Authentication:** Required

**Path Parameters:**
- `bookingId` (required): Booking ID

**Response:** `200 OK` (RatingResponse) or `404 Not Found`

---

## Notifications

### GET /api/notifications/me

Get all notifications for current user.

**Authentication:** Required

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "userId": 1,
    "type": "BOOKING_CONFIRMED",
    "title": "Booking Confirmed",
    "body": "Your booking for ride #123 has been confirmed",
    "read": false,
    "createdAt": "2024-01-15T10:30:00"
  }
]
```

---

### GET /api/notifications/me/unread

Get unread notifications for current user.

**Authentication:** Required

**Response:** `200 OK` (array of NotificationResponse)

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

---

### POST /api/notifications/{id}/read

Mark a notification as read.

**Authentication:** Required

**Path Parameters:**
- `id` (required): Notification ID

**Response:** `200 OK` (empty body)

---

### POST /api/notifications/me/read-all

Mark all notifications as read.

**Authentication:** Required

**Response:** `200 OK` (empty body)

---

## Analytics

### GET /api/analytics/driver/earnings

Get driver earnings analytics.

**Authentication:** Required (Driver role)

**Query Parameters:**
- `from` (optional): Start date (ISO format: YYYY-MM-DD)
- `to` (optional): End date (ISO format: YYYY-MM-DD)

**Example:** `/api/analytics/driver/earnings?from=2024-01-01&to=2024-01-31`

**Response:** `200 OK`
```json
{
  "driverId": 1,
  "totalEarnings": 500.00,
  "totalRides": 25,
  "periodFrom": "2024-01-01",
  "periodTo": "2024-01-31"
}
```

---

### GET /api/analytics/rider/spending

Get rider spending analytics.

**Authentication:** Required (Rider role)

**Query Parameters:**
- `from` (optional): Start date (ISO format: YYYY-MM-DD)
- `to` (optional): End date (ISO format: YYYY-MM-DD)

**Response:** `200 OK`
```json
{
  "riderId": 2,
  "totalSpending": 300.00,
  "totalBookings": 15,
  "periodFrom": "2024-01-01",
  "periodTo": "2024-01-31"
}
```

---

### GET /api/analytics/rides/stats

Get ride statistics for current user.

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "totalRides": 50,
  "completedRides": 45,
  "cancelledRides": 3,
  "activeRides": 2
}
```

---

### GET /api/analytics/bookings/stats

Get booking statistics (Admin only).

**Authentication:** Required (Admin role)

**Response:** `200 OK`
```json
{
  "totalBookings": 500,
  "confirmedBookings": 450,
  "cancelledBookings": 30,
  "successRate": 0.90
}
```

---

### GET /api/analytics/destinations/popular

Get popular destinations (Admin only).

**Authentication:** Required (Admin role)

**Query Parameters:**
- `limit` (optional): Number of results (default: 10)

**Example:** `/api/analytics/destinations/popular?limit=20`

**Response:** `200 OK`
```json
{
  "destinations": [
    {
      "locationId": 1,
      "locationLabel": "University Main Gate",
      "rideCount": 150
    },
    {
      "locationId": 2,
      "locationLabel": "City Center",
      "rideCount": 120
    }
  ]
}
```

---

### GET /api/analytics/times/peak

Get peak times analysis (Admin only).

**Authentication:** Required (Admin role)

**Response:** `200 OK`
```json
{
  "peakTimes": [
    {
      "hour": 8,
      "rideCount": 45
    },
    {
      "hour": 17,
      "rideCount": 52
    }
  ]
}
```

---

### GET /api/analytics/dashboard

Get dashboard statistics (Admin only).

**Authentication:** Required (Admin role)

**Response:** `200 OK`
```json
{
  "totalUsers": 1000,
  "totalRides": 5000,
  "activeRides": 25,
  "totalRevenue": 50000.00
}
```

---

## Admin Endpoints

All admin endpoints require `ADMIN` role.

### GET /api/admin/users

Get all users.

**Authentication:** Required (Admin role)

**Response:** `200 OK` (array of UserResponse)

---

### GET /api/admin/users/{id}

Get user by ID.

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (required): User ID

**Response:** `200 OK` (UserResponse)

---

### PUT /api/admin/users/{id}/enable

Enable or disable a user.

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (required): User ID

**Request Body:**
```json
{
  "enabled": true
}
```

**Field Descriptions:**
- `enabled` (required): Enable/disable user account

**Response:** `200 OK` (UserResponse)

---

### POST /api/admin/users/{id}/upload-university-id

Upload university ID image for a user (admin override).

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (required): User ID

**Request Body:**
```json
{
  "imageData": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
}
```

**Field Descriptions:**
- `imageData` (required): Base64 encoded image data

**Response:** `200 OK` (UserResponse)

---

### POST /api/admin/users/{id}/upload-drivers-license

Upload driver's license image for a user (admin override).

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (required): User ID

**Request Body:**
```json
{
  "imageData": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
}
```

**Field Descriptions:**
- `imageData` (required): Base64 encoded image data

**Response:** `200 OK` (UserResponse)

---

### PUT /api/admin/users/{id}/verify-university-id

Verify or reject a user's university ID.

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (required): User ID

**Request Body:**
```json
{
  "verified": true
}
```

**Field Descriptions:**
- `verified` (required): Set to `true` to verify the university ID, `false` to reject

**Response:** `200 OK` (UserResponse)

**Note:** Only verified university students can book rides.

---

### PUT /api/admin/users/{id}/verify-driver

Verify or reject a user as a driver.

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (required): User ID

**Request Body:**
```json
{
  "verified": true
}
```

**Field Descriptions:**
- `verified` (required): Set to `true` to verify the driver, `false` to reject

**Response:** `200 OK` (UserResponse)

**Note:** Only verified drivers can post rides.

---

### GET /api/admin/rides

Get all rides.

**Authentication:** Required (Admin role)

**Response:** `200 OK` (array of Ride entities)

---

### GET /api/admin/rides/{id}

Get ride by ID.

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (required): Ride ID

**Response:** `200 OK` (Ride entity)

---

### PUT /api/admin/rides/{id}/complete

Force complete a ride.

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (required): Ride ID

**Response:** `200 OK` (empty body)

---

### GET /api/admin/bookings

Get all bookings.

**Authentication:** Required (Admin role)

**Response:** `200 OK` (array of Booking entities)

---

### GET /api/admin/bookings/{id}

Get booking by ID.

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (required): Booking ID

**Response:** `200 OK` (Booking entity)

---

### GET /api/admin/payments

Get all payments.

**Authentication:** Required (Admin role)

**Response:** `200 OK` (array of Payment entities)

---

### GET /api/admin/payments/{id}

Get payment by ID.

**Authentication:** Required (Admin role)

**Path Parameters:**
- `id` (required): Payment ID

**Response:** `200 OK` (Payment entity)

---

### POST /api/admin/database/reset

Reset the entire database by deleting all data.

**Authentication:** Required (Admin role)

**Warning:** This operation is irreversible and will delete all data from the database including:
- All users (except the default admin account will be recreated on next startup)
- All rides
- All bookings
- All payments
- All ratings
- All notifications
- All locations
- All vehicles
- All GPS tracking data
- All routes

**Response:** `200 OK` (empty body)

**Status Codes:**
- `200 OK` - Database reset successfully
- `403 Forbidden` - Admin access required

**Note:** After resetting the database, the default admin account (configured in `application.properties`) will be automatically recreated on the next application startup if it doesn't exist.

---

## Data Models

### Enums

#### Role
- `RIDER` - User can only book rides
- `DRIVER` - User can only create rides
- `BOTH` - User can both create and book rides
- `ADMIN` - Administrative access

#### RideStatus
- `POSTED` - Ride is posted and accepting bookings
- `IN_PROGRESS` - Ride is currently in progress
- `COMPLETED` - Ride has been completed
- `CANCELLED` - Ride has been cancelled

#### BookingStatus
- `PENDING` - Booking is pending confirmation
- `CONFIRMED` - Booking is confirmed
- `CANCELLED` - Booking has been cancelled
- `COMPLETED` - Booking has been completed

#### PaymentStatus
- `INITIATED` - Payment has been initiated
- `PROCESSING` - Payment is being processed
- `SETTLED` - Payment has been settled
- `FAILED` - Payment failed
- `REFUNDED` - Payment has been refunded

#### PaymentMethod
- `CARD_SIMULATED` - Simulated card payment
- `CASH` - Cash payment
- `WALLET` - Wallet balance payment

#### NotificationType
- `BOOKING_CONFIRMED` - Booking confirmed notification
- `BOOKING_CANCELLED` - Booking cancelled notification
- `PAYMENT_RECEIVED` - Payment received notification
- `RIDE_REMINDER` - Ride reminder notification
- `RIDE_IN_PROGRESS` - Ride in progress notification
- `RIDE_COMPLETED` - Ride completed notification

### Request DTOs

#### RegisterRequest
```json
{
  "universityId": "string (required)",
  "email": "string (required, valid email)",
  "password": "string (required)",
  "fullName": "string (required)",
  "phoneNumber": "string (optional)",
  "role": "string (optional: RIDER, DRIVER, BOTH) - ADMIN role is not allowed during registration"
}
```

#### LoginRequest
```json
{
  "email": "string (required, valid email)",
  "password": "string (required)"
}
```

#### UpdateUserRequest
```json
{
  "fullName": "string (required)",
  "phoneNumber": "string (optional)"
}
```

#### ChangePasswordRequest
```json
{
  "oldPassword": "string (required)",
  "newPassword": "string (required)"
}
```

#### UpdateSettingsRequest
```json
{
  "emailNotifications": "boolean (optional)",
  "smsNotifications": "boolean (optional)",
  "pushNotifications": "boolean (optional)",
  "allowSmoking": "boolean (optional)",
  "allowPets": "boolean (optional)",
  "allowMusic": "boolean (optional)",
  "preferQuietRides": "boolean (optional)",
  "showPhoneNumber": "boolean (optional)",
  "showEmail": "boolean (optional)",
  "autoAcceptBookings": "boolean (optional)",
  "preferredPaymentMethod": "string (optional: CARD_SIMULATED, CASH, WALLET)"
}
```

#### UploadImageRequest
```json
{
  "imageData": "string (required, base64 encoded image data)"
}
```

#### VerifyUserRequest
```json
{
  "verified": "boolean (required)"
}
```

#### CreateVehicleRequest
```json
{
  "make": "string (required)",
  "model": "string (required)",
  "color": "string (optional)",
  "plateNumber": "string (required)",
  "seatCount": "integer (required, positive)"
}
```

#### UpdateVehicleRequest
```json
{
  "make": "string (optional)",
  "model": "string (optional)",
  "color": "string (optional)",
  "plateNumber": "string (optional)",
  "seatCount": "integer (optional, positive)",
  "active": "boolean (optional)"
}
```

#### CreateLocationRequest
```json
{
  "label": "string (required)",
  "address": "string (optional)",
  "latitude": "number (required)",
  "longitude": "number (required)",
  "isFavorite": "boolean (optional)"
}
```

#### SearchLocationRequest
```json
{
  "query": "string (required)"
}
```

#### CreateRideRequest
```json
{
  "vehicleId": "integer (required)",
  "pickupLocationId": "integer (required)",
  "destinationLocationId": "integer (required)",
  "departureTime": "datetime (required, ISO format, future date)",
  "totalSeats": "integer (required, positive)",
  "basePrice": "decimal (optional)",
  "pricePerSeat": "decimal (optional)"
}
```

#### UpdateRideRequest
```json
{
  "pickupLocationId": "integer (optional)",
  "destinationLocationId": "integer (optional)",
  "departureTime": "datetime (optional, ISO format, future date)",
  "totalSeats": "integer (optional, positive)",
  "basePrice": "decimal (optional)",
  "pricePerSeat": "decimal (optional)"
}
```

#### SearchRidesRequest
```json
{
  "pickupLocationId": "integer (optional)",
  "pickupLatitude": "number (optional)",
  "pickupLongitude": "number (optional)",
  "pickupRadiusKm": "number (optional)",
  "destinationLocationId": "integer (optional)",
  "destinationLatitude": "number (optional)",
  "destinationLongitude": "number (optional)",
  "destinationRadiusKm": "number (optional)",
  "departureTimeFrom": "datetime (optional, ISO format)",
  "departureTimeTo": "datetime (optional, ISO format)",
  "minAvailableSeats": "integer (optional)",
  "maxPrice": "decimal (optional)",
  "sortBy": "string (optional: distance, price, departureTime)"
}
```

#### CreateBookingRequest
```json
{
  "rideId": "integer (required)",
  "seats": "integer (required, positive, cannot exceed ride capacity)",
  "pickupLocationId": "integer (required)",
  "dropoffLocationId": "integer (required)",
  "pickupTimeStart": "datetime (required, ISO format, future date, within ride's departure time range)",
  "pickupTimeEnd": "datetime (required, ISO format, future date, after pickupTimeStart, within ride's departure time range, max 2 hours after pickupTimeStart)"
}
```

#### UpdateBookingStatusRequest
```json
{
  "status": "string (required: CONFIRMED or CANCELLED)"
}
```

#### InitiatePaymentRequest
```json
{
  "bookingId": "integer (required)",
  "method": "string (required: CARD_SIMULATED, CASH, WALLET)"
}
```

#### WalletTopUpRequest
```json
{
  "amount": "decimal (required, positive)"
}
```

#### CreateRatingRequest
```json
{
  "bookingId": "integer (required)",
  "score": "integer (required, 1-5)",
  "comment": "string (optional)"
}
```

### Response DTOs

#### UserResponse
```json
{
  "id": "integer",
  "universityId": "string",
  "email": "string",
  "fullName": "string",
  "phoneNumber": "string",
  "universityIdImage": "string (nullable, base64 encoded image or file path)",
  "driversLicenseImage": "string (nullable, base64 encoded image or file path)",
  "universityIdVerified": "boolean",
  "verifiedDriver": "boolean",
  "role": "Role enum",
  "enabled": "boolean",
  "createdAt": "datetime (ISO format)",
  "walletBalance": "decimal",
  "avgRatingAsDriver": "decimal (nullable)",
  "ratingCountAsDriver": "integer",
  "avgRatingAsRider": "decimal (nullable)",
  "ratingCountAsRider": "integer"
}
```

#### VehicleResponse
```json
{
  "id": "integer",
  "make": "string",
  "model": "string",
  "color": "string",
  "plateNumber": "string",
  "seatCount": "integer",
  "ownerId": "integer",
  "ownerName": "string",
  "active": "boolean",
  "createdAt": "datetime (ISO format)"
}
```

#### LocationResponse
```json
{
  "id": "integer",
  "label": "string",
  "address": "string",
  "latitude": "number",
  "longitude": "number",
  "userId": "integer",
  "isFavorite": "boolean"
}
```

#### RideResponse
```json
{
  "id": "integer",
  "driverId": "integer",
  "driverName": "string",
  "driverRating": "decimal",
  "vehicleId": "integer",
  "vehicleMake": "string",
  "vehicleModel": "string",
  "vehiclePlateNumber": "string",
  "vehicleSeatCount": "integer",
  "pickupLocationId": "integer",
  "pickupLocationLabel": "string",
  "pickupLatitude": "number",
  "pickupLongitude": "number",
  "destinationLocationId": "integer",
  "destinationLocationLabel": "string",
  "destinationLatitude": "number",
  "destinationLongitude": "number",
  "departureTime": "datetime (ISO format)",
  "totalSeats": "integer",
  "availableSeats": "integer",
  "estimatedDistanceKm": "number",
  "routeDistanceKm": "number",
  "estimatedDurationMinutes": "integer",
  "basePrice": "decimal",
  "pricePerSeat": "decimal",
  "status": "RideStatus enum",
  "createdAt": "datetime (ISO format)",
  "routePolyline": "string"
}
```

#### BookingResponse
```json
{
  "bookingId": "integer",
  "rideId": "integer",
  "passengerId": "integer",
  "passengerName": "string",
  "seatsBooked": "integer",
  "pickupLocationId": "integer",
  "pickupLocationLabel": "string",
  "pickupLatitude": "number",
  "pickupLongitude": "number",
  "dropoffLocationId": "integer",
  "dropoffLocationLabel": "string",
  "dropoffLatitude": "number",
  "dropoffLongitude": "number",
  "pickupTimeStart": "datetime (ISO format)",
  "pickupTimeEnd": "datetime (ISO format)",
  "createdAt": "datetime (ISO format)",
  "status": "BookingStatus enum (PENDING, CONFIRMED, CANCELLED, COMPLETED)",
  "costForThisRider": "decimal",
  "cancelledAt": "datetime (ISO format, nullable)"
}
```

#### PaymentResponse
```json
{
  "id": "integer",
  "bookingId": "integer",
  "payerId": "integer",
  "payerName": "string",
  "driverId": "integer",
  "driverName": "string",
  "amount": "decimal",
  "platformFee": "decimal",
  "driverEarnings": "decimal",
  "method": "PaymentMethod enum",
  "status": "PaymentStatus enum",
  "transactionRef": "string",
  "createdAt": "datetime (ISO format)",
  "updatedAt": "datetime (ISO format)"
}
```

#### RatingResponse
```json
{
  "id": "integer",
  "fromUserId": "integer",
  "fromUserName": "string",
  "toUserId": "integer",
  "toUserName": "string",
  "bookingId": "integer",
  "score": "integer (1-5)",
  "comment": "string",
  "createdAt": "datetime (ISO format)"
}
```

#### NotificationResponse
```json
{
  "id": "integer",
  "userId": "integer",
  "type": "NotificationType enum",
  "title": "string",
  "body": "string",
  "read": "boolean",
  "createdAt": "datetime (ISO format)"
}
```

---

## Status Codes and Errors

### Success Status Codes

- **200 OK** - Request successful
- **201 Created** - Resource created successfully

### Client Error Status Codes

- **400 Bad Request** - Invalid request data or validation errors
  ```json
  {
    "fieldName": "Error message",
    "status": 400,
    "timestamp": "2024-01-15T10:30:00"
  }
  ```

- **401 Unauthorized** - Authentication required or invalid token
  ```json
  {
    "message": "User not authenticated",
    "status": 401,
    "timestamp": "2024-01-15T10:30:00"
  }
  ```

- **403 Forbidden** - Insufficient permissions
  ```json
  {
    "message": "Admin access required",
    "status": 403,
    "timestamp": "2024-01-15T10:30:00"
  }
  ```

- **404 Not Found** - Resource not found
  ```json
  {
    "message": "Ride not found",
    "status": 404,
    "timestamp": "2024-01-15T10:30:00"
  }
  ```

- **409 Conflict** - Resource conflict (e.g., duplicate email)

### Server Error Status Codes

- **500 Internal Server Error** - Unexpected server error
  ```json
  {
    "message": "An unexpected error occurred",
    "status": 500,
    "timestamp": "2024-01-15T10:30:00"
  }
  ```

### Custom Domain Errors

The API uses custom exception types that map to HTTP status codes:

- **ResourceNotFoundException** → 404 Not Found
- **UnauthorizedException** → 401 Unauthorized
- **ForbiddenException** → 403 Forbidden
- **BusinessException** → 400 Bad Request

---

## Frontend Integration Guide

### Base Configuration

**Base URL:** `http://localhost:8080/api`

**Default Headers:**
```javascript
{
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${token}`
}
```

### React/JavaScript Example

#### Setup Axios Instance

```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8080/api',
  headers: {
    'Content-Type': 'application/json'
  }
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle token expiration
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
```

#### Authentication Example

```javascript
// Register
const register = async (userData) => {
  try {
    const response = await api.post('/auth/register', userData);
    const { token, user } = response.data;
    localStorage.setItem('token', token);
    return { token, user };
  } catch (error) {
    throw error.response?.data || error.message;
  }
};

// Login
const login = async (email, password) => {
  try {
    const response = await api.post('/auth/login', { email, password });
    const { token, user } = response.data;
    localStorage.setItem('token', token);
    return { token, user };
  } catch (error) {
    throw error.response?.data || error.message;
  }
};

// Get current user
const getCurrentUser = async () => {
  try {
    const response = await api.get('/auth/me');
    return response.data;
  } catch (error) {
    throw error.response?.data || error.message;
  }
};
```

#### Ride Search Example

```javascript
// Search rides with filters
const searchRides = async (filters) => {
  try {
    const response = await api.post('/rides/search', filters);
    return response.data;
  } catch (error) {
    throw error.response?.data || error.message;
  }
};

// Usage
const filters = {
  pickupLatitude: 40.7128,
  pickupLongitude: -74.0060,
  pickupRadiusKm: 5.0,
  destinationLatitude: 40.7580,
  destinationLongitude: -73.9855,
  destinationRadiusKm: 5.0,
  departureTimeFrom: '2024-01-20T00:00:00',
  departureTimeTo: '2024-01-20T23:59:59',
  minAvailableSeats: 2,
  maxPrice: 50.00,
  sortBy: 'distance'
};

const rides = await searchRides(filters);
```

#### Create Booking Example

```javascript
const createBooking = async (rideId, seats) => {
  try {
    const response = await api.post('/bookings', {
      rideId,
      seats
    });
    return response.data;
  } catch (error) {
    if (error.response?.status === 400) {
      // Handle validation errors
      console.error('Validation errors:', error.response.data);
    }
    throw error.response?.data || error.message;
  }
};
```

#### Error Handling

```javascript
const handleApiError = (error) => {
  if (error.response) {
    // Server responded with error
    const { status, data } = error.response;
    
    switch (status) {
      case 400:
        // Validation errors
        if (typeof data === 'object' && !data.message) {
          // Field-specific errors
          Object.keys(data).forEach(field => {
            console.error(`${field}: ${data[field]}`);
          });
        } else {
          console.error(data.message || 'Bad request');
        }
        break;
      case 401:
        // Unauthorized - redirect to login
        localStorage.removeItem('token');
        window.location.href = '/login';
        break;
      case 403:
        console.error('Access forbidden:', data.message);
        break;
      case 404:
        console.error('Resource not found:', data.message);
        break;
      case 500:
        console.error('Server error:', data.message);
        break;
      default:
        console.error('Unexpected error:', data.message);
    }
  } else if (error.request) {
    // Request made but no response
    console.error('Network error: No response from server');
  } else {
    // Error setting up request
    console.error('Error:', error.message);
  }
};
```

### Flutter/Dart Example

#### HTTP Client Setup

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  static const String baseUrl = 'http://localhost:8080/api';
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Future<http.Response> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    _handleError(response);
    return response;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    _handleError(response);
    return response;
  }

  static void _handleError(http.Response response) {
    if (response.statusCode == 401) {
      // Token expired
      _token = null;
      // Navigate to login
    }
  }
}
```

#### Authentication Example

```dart
// Register
Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
  final response = await ApiClient.post('/auth/register', userData);
  final data = jsonDecode(response.body);
  ApiClient.setToken(data['token']);
  return data;
}

// Login
Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await ApiClient.post('/auth/login', {
    'email': email,
    'password': password,
  });
  final data = jsonDecode(response.body);
  ApiClient.setToken(data['token']);
  return data;
}
```

### Token Storage Best Practices

1. **Web (React/Next.js):**
    - Use `localStorage` for persistence (not secure for sensitive data)
    - Consider `httpOnly` cookies for production
    - Clear token on logout

2. **Mobile (Flutter/React Native):**
    - Use secure storage (e.g., `flutter_secure_storage`, `@react-native-async-storage/async-storage`)
    - Never store tokens in plain text
    - Implement token refresh if available

3. **Token Expiration:**
    - Tokens expire after 24 hours
    - Implement automatic logout on 401 responses
    - Consider implementing refresh token mechanism

### Pagination and Filtering

The ride search endpoint supports flexible filtering:

```javascript
// Example: Search with location-based filtering
const searchParams = {
  pickupLatitude: userLocation.lat,
  pickupLongitude: userLocation.lng,
  pickupRadiusKm: 10, // 10km radius
  destinationLatitude: destination.lat,
  destinationLongitude: destination.lng,
  destinationRadiusKm: 5, // 5km radius
  departureTimeFrom: new Date().toISOString(),
  minAvailableSeats: 1,
  sortBy: 'departureTime' // or 'distance', 'price'
};
```

### Real-time Updates

For GPS tracking and notifications, consider implementing:

1. **Polling:** Periodically fetch updates
   ```javascript
   setInterval(async () => {
     const location = await api.get(`/tracking/${rideId}`);
     updateMap(location.data);
   }, 30000); // Every 30 seconds
   ```

2. **WebSockets:** (if implemented) Connect to WebSocket endpoint for real-time updates

---

## Additional Notes

- All datetime fields use ISO 8601 format (e.g., `2024-01-15T10:30:00`)
- All monetary values are in decimal format (e.g., `10.50`)
- Coordinate values are in decimal degrees (latitude/longitude)
- Distance values are in kilometers
- Duration values are in minutes
- The platform fee is 10% of the payment amount (configurable in `application.properties`)

---

**API Version:** 0.0.1-SNAPSHOT  
**Last Updated:** 2024-01-15