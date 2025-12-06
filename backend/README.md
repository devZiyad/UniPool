# UniPool Backend

A comprehensive RESTful API service for university ride-sharing, enabling students to post rides, search for available rides, book seats, and manage the complete lifecycle of shared transportation within a university community.

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Database Setup](#database-setup)
- [Running the Backend](#running-the-backend)
- [Environment Variables](#environment-variables)
- [Build Instructions](#build-instructions)
- [Testing](#testing)
- [API Authentication](#api-authentication)
- [Contribution](#contribution)
- [License](#license)
- [Quick Start Examples](#quick-start-examples)

## Project Overview

UniPool Backend is a production-ready Spring Boot application that provides a secure, scalable foundation for a university ride-sharing platform. The system manages user authentication, ride postings, booking management, payment processing, GPS tracking, ratings, notifications, and comprehensive administrative tools.

The backend follows RESTful API design principles with clear separation between controllers, services, repositories, and data models. It implements JWT-based authentication, role-based access control, content filtering, and comprehensive audit logging.

## Features

### Core Functionality

- **User Management**: Registration, authentication, profile management, role-based access control
- **Vehicle Management**: Vehicle registration, activation, and ownership tracking
- **Ride Management**: Post rides, search with advanced filters, status tracking, cancellation
- **Booking System**: Seat booking, status management, cancellation, cost calculation
- **Payment Processing**: Multiple payment methods (card, cash, wallet), platform fee calculation, wallet management
- **Rating System**: Post-ride ratings with comments, average rating calculation
- **GPS Tracking**: Real-time location updates for active rides, tracking start/stop
- **Location Management**: Location creation, favorites, distance calculation, reverse geocoding
- **Notifications**: In-app notifications, unread tracking, automated ride reminders
- **Analytics**: Driver earnings, rider spending, ride statistics, popular destinations, peak times
- **Content Moderation**: Profanity filtering, XSS protection, user reporting, admin moderation
- **Administrative Tools**: User management, ride/booking oversight, database management

### Security Features

- JWT-based authentication with 24-hour token expiration
- BCrypt password hashing
- Rate limiting (100 req/min general, 5 req/min for auth endpoints)
- Content filtering and sanitization
- Role-based access control (RIDER, DRIVER, BOTH, ADMIN)
- Audit logging for administrative actions

## Architecture

The application follows a layered architecture:

```
┌─────────────────────────────────────┐
│      REST Controllers (API Layer)   │
├─────────────────────────────────────┤
│      Service Layer (Business Logic)  │
├─────────────────────────────────────┤
│      Repository Layer (Data Access)  │
├─────────────────────────────────────┤
│      Entity Models (Domain Layer)    │
└─────────────────────────────────────┘
```

### Key Components

- **Controllers**: Handle HTTP requests and responses, validate input
- **Services**: Implement business logic, orchestrate operations
- **Repositories**: Data access layer using Spring Data JPA
- **Security**: JWT authentication filter, rate limiting filter, security configuration
- **Utilities**: Distance calculation, routing, geocoding, content filtering

## Tech Stack

- **Framework**: Spring Boot 4.0.0
- **Language**: Java 17
- **Build Tool**: Maven
- **Database**: H2 Database (file-based for development)
- **ORM**: Spring Data JPA with Hibernate
- **Security**: Spring Security with JWT (JJWT 0.13.0)
- **Validation**: Jakarta Bean Validation
- **Rate Limiting**: Bucket4j 8.10.1
- **Testing**: JUnit 5, MockMvc
- **Utilities**: Lombok, Jackson (JSR310 support)

## Installation

### Prerequisites

- Java 17 or higher
- Maven 3.6 or higher
- Git

### Clone the Repository

```bash
git clone <repository-url>
cd UniPoolBackend
```

### Build the Project

Using Maven wrapper (recommended):

```bash
./mvnw clean install
```

Or using Maven directly:

```bash
mvn clean install
```

## Database Setup

The application uses H2 Database configured as a file-based database. The database file is automatically created at `./data/unipool.mv.db` on first run.

### H2 Console

Access the H2 database console at:

```
http://localhost:8080/h2-console
```

**Connection Settings:**
- JDBC URL: `jdbc:h2:file:./data/unipool`
- Username: `sa`
- Password: (empty)

### Database Schema

The schema is automatically created/updated by Hibernate based on entity classes. No manual schema setup is required.

### Default Admin Account

A default admin account is automatically created on application startup:

- **Email**: `admin@unipool.edu`
- **Password**: `admin123`
- **University ID**: `ADMIN001`

**Note**: Change the default admin password immediately in production environments.

## Running the Backend

### Using Maven Wrapper

```bash
./mvnw spring-boot:run
```

### Using Maven

```bash
mvn spring-boot:run
```

### Using IDE

1. Open the project in your IDE (IntelliJ IDEA, Eclipse, VS Code)
2. Locate `UniPoolBackendApplication.java`
3. Run the main method

### Expected Startup

Upon successful startup, you should see:

- Spring Boot application starting
- H2 database initialization
- JPA entity scanning
- Security configuration loading
- Server starting on port 8080

### Default Port

The application runs on port **8080** by default.

**Base URL**: `http://localhost:8080`

**API Base URL**: `http://localhost:8080/api`

## Environment Variables

The application configuration is located in `src/main/resources/application.properties`. Key configuration options:

### Database Configuration

```properties
spring.datasource.url=jdbc:h2:file:./data/unipool
spring.datasource.username=sa
spring.datasource.password=
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
spring.jpa.hibernate.ddl-auto=update
```

### JWT Configuration

```properties
jwt.secret=y9OkM2UnHNKLK0pc4HuQ/BuxOsCxliwstKvJxJAh5d4=
jwt.expiration=86400000  # 24 hours in milliseconds
```

### Server Configuration

```properties
server.port=8080
```

### CORS Configuration

```properties
cors.allowed-origins=*
```

**Note**: Adjust CORS settings for production to restrict origins.

### Payment Configuration

```properties
payment.platform-fee-percentage=10  # 10% platform fee
```

### GPS Tracking Configuration

```properties
gps.tracking.update-interval-seconds=30
```

### Application Version

```properties
app.version=0.0.1-SNAPSHOT
```

### Default Admin Account

```properties
admin.default.email=admin@unipool.edu
admin.default.password=admin123
admin.default.universityId=ADMIN001
admin.default.fullName=System Administrator
```

## Build Instructions

### Build JAR File

```bash
./mvnw clean package
```

The JAR file will be created in `target/UniPoolBackend-0.0.1-SNAPSHOT.jar`

### Run JAR File

```bash
java -jar target/UniPoolBackend-0.0.1-SNAPSHOT.jar
```

### Build with Tests

```bash
./mvnw clean install
```

### Skip Tests During Build

```bash
./mvnw clean install -DskipTests
```

## Testing

### Run All Tests

```bash
./mvnw test
```

Or:

```bash
mvn test
```

### Test Suite Structure

Integration tests are located in `src/test/java/me/devziyad/unipoolbackend/`:

- `AuthControllerIT`: Authentication and registration tests
- `UserControllerIT`: User management endpoint tests
- `BookingControllerIT`: Booking creation and management tests
- `RideControllerIT`: Ride posting and search tests
- `PaymentControllerIT`: Payment processing tests
- `AdminControllerIT`: Administrative endpoint tests
- `HealthControllerIT`: Health check endpoint tests

### Test Configuration

Tests use:
- **MockMvc**: For simulating HTTP requests
- **H2 In-Memory Database**: For isolated test data
- **JWT Service**: For generating test authentication tokens
- **@Transactional**: For test data isolation

## API Authentication

### JWT Authentication

The API uses JSON Web Tokens (JWT) for authentication. Most endpoints require a valid JWT token in the Authorization header.

### Getting a Token

**Register a new user:**

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "universityId": "S123456",
    "email": "user@university.edu",
    "password": "SecurePass123!",
    "fullName": "John Doe",
    "phoneNumber": "+1234567890",
    "role": "RIDER"
  }'
```

**Login:**

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@university.edu",
    "password": "SecurePass123!"
  }'
```

Both endpoints return a JWT token in the response:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { ... }
}
```

### Using the Token

Include the token in the `Authorization` header for protected endpoints:

```bash
curl -X GET http://localhost:8080/api/users/me \
  -H "Authorization: Bearer <your-token>"
```

### Token Expiration

Tokens expire after 24 hours (86400000 milliseconds). When a token expires, you'll receive a `401 Unauthorized` response. Re-authenticate to get a new token.

### Public Endpoints

The following endpoints do not require authentication:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/health`

All other endpoints require a valid JWT token.

## Contribution

### Guidelines

- Follow Java coding conventions and best practices
- Maintain consistent code formatting
- Write meaningful commit messages
- Include tests for new features
- Update documentation when adding new endpoints

### Branching Strategy

- Use feature branches for new development
- Create branches from the main branch
- Use descriptive branch names (e.g., `feature/user-settings`, `fix/payment-calculation`)

### Commit Messages

Follow conventional commit message format:

```
<type>: <description>

[optional body]

[optional footer]
```

**Types**: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`

**Example:**

```
feat: Add user settings endpoint

Implement user preferences management with notification settings
and ride preferences.
```

### Code Quality

- Ensure all tests pass before submitting changes
- Run `mvn clean install` to verify the build
- Check for linter warnings and resolve them
- Maintain null-safety annotations where applicable

### Pull Request Process

1. Create a feature branch
2. Make your changes
3. Write/update tests
4. Update documentation
5. Ensure all tests pass
6. Submit a pull request with a clear description

## License

This project is developed for academic purposes. License information will be added as needed.

## Quick Start Examples

### 1. Register and Get Token

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "universityId": "S123456",
    "email": "john.doe@university.edu",
    "password": "SecurePass123!",
    "fullName": "John Doe",
    "role": "RIDER"
  }'
```

### 2. Get Current User Profile

```bash
TOKEN="<your-token>"
curl -X GET http://localhost:8080/api/users/me \
  -H "Authorization: Bearer $TOKEN"
```

### 3. Create a Vehicle (Driver)

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

### 4. Create a Ride

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

### 5. Search for Rides

```bash
curl -X POST http://localhost:8080/api/rides/search \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "pickupLocationId": 1,
    "destinationLocationId": 2,
    "departureTimeFrom": "2024-12-15T00:00:00",
    "minAvailableSeats": 1
  }'
```

### 6. Book a Ride

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

### 7. Check Health

```bash
curl -X GET http://localhost:8080/api/health
```

For complete API documentation with all endpoints, request/response examples, and validation rules, see [API_DOCUMENTATION.md](docs/API_DOCUMENTATION.md).
