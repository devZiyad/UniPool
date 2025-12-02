# UniPool Backend

## Project Overview

UniPool Backend is a comprehensive RESTful API service designed to facilitate ride-sharing among university students. The system enables students to post available rides, search for rides, book seats, and manage the complete lifecycle of shared transportation within a university community.

The backend is responsible for managing user authentication and authorization, ride postings and matching, booking management, payment processing simulation, GPS tracking, rating systems, and administrative analytics. It provides a secure, scalable foundation for a university ride-sharing platform.

The architecture follows a layered approach with clear separation between controllers, services, repositories, and data models. The system uses Spring Boot's dependency injection and follows RESTful API design principles to ensure maintainability and extensibility.

## Features

### Authentication and Authorization

- JWT-based authentication system
- User registration and login endpoints
- Role-based access control (RIDER, DRIVER, BOTH, ADMIN)
- Secure password hashing using BCrypt
- Token expiration and refresh handling
- Protected endpoints with Spring Security

### User Management

- User profile creation and management
- University ID validation
- User settings configuration
- Password change functionality
- Role management
- User statistics and ratings tracking

### Vehicle Management

- Vehicle registration and ownership tracking
- Vehicle activation and deactivation
- Multiple vehicle support per user
- Vehicle information retrieval

### Ride Management

- Ride posting with detailed information
- Ride search with filtering capabilities
- Location-based ride matching
- Ride status updates (POSTED, IN_PROGRESS, COMPLETED, CANCELLED)
- Available seats tracking
- Route distance and duration estimation
- Ride cancellation functionality

### Location Handling and Routing

- Location creation and management
- Favorite locations support
- Distance calculation between locations
- Reverse geocoding functionality
- Location search integration
- Route polyline storage

### GPS Tracking

- Real-time location updates for active rides
- GPS tracking start and stop functionality
- Location history tracking
- Active ride monitoring

### Booking System

- Seat booking for available rides
- Booking status management (PENDING, CONFIRMED, CANCELLED)
- Booking cancellation
- Booking history tracking
- Cost calculation per booking

### Rating System

- Post-ride rating submission
- Driver and rider rating separation
- Average rating calculation
- Rating history retrieval
- Comment support for ratings

### Notification System

- In-app notification generation
- Notification types (BOOKING, RIDE, PAYMENT, RATING, SYSTEM)
- Unread notification tracking
- Notification marking as read
- Bulk read operations
- Automated ride reminder scheduling

### Payment Simulation Module

- Payment initiation and processing
- Multiple payment methods (CARD_SIMULATED, CASH, WALLET)
- Wallet balance management
- Wallet top-up functionality
- Platform fee calculation
- Driver earnings tracking
- Payment status management
- Transaction reference generation

### Analytics and Administrative Tools

- Driver earnings analytics
- Rider spending analytics
- Ride statistics
- Booking statistics
- Popular destinations tracking
- Peak times analysis
- Dashboard statistics for administrators
- User management tools
- Ride and booking oversight

### Health Check Endpoint

- System health monitoring
- Version information
- Timestamp tracking
- Public accessibility

## Technology Stack

- **Spring Boot 4.0.0**: Main application framework
- **Java 17**: Programming language
- **Spring Data JPA**: Data persistence abstraction
- **Hibernate**: JPA implementation and ORM
- **H2 Database**: In-memory database for development and testing
- **Maven**: Build automation and dependency management
- **Spring Security**: Authentication and authorization framework
- **JWT (JSON Web Tokens)**: Token-based authentication using JJWT 0.13.0
- **Lombok**: Code generation for reducing boilerplate
- **Jakarta Validation**: Bean validation framework
- **Spring WebFlux**: Reactive programming support
- **JUnit 5**: Testing framework
- **MockMvc**: Spring MVC testing support

## Project Structure

```
src/
├── main/
│   ├── java/
│   │   └── me/devziyad/unipoolbackend/
│   │       ├── admin/              # Administrative endpoints and functionality
│   │       ├── analytics/          # Analytics service and DTOs
│   │       ├── auth/               # Authentication and authorization
│   │       ├── booking/            # Booking management system
│   │       ├── common/             # Shared enums (Role, Status, etc.)
│   │       ├── controller/         # Health check endpoint
│   │       ├── exception/          # Custom exception classes and global handler
│   │       ├── location/           # Location management and geocoding
│   │       ├── notification/       # Notification service and scheduling
│   │       ├── payment/            # Payment processing simulation
│   │       ├── rating/             # Rating system implementation
│   │       ├── ride/               # Ride posting and management
│   │       ├── route/               # Route information and stops
│   │       ├── security/           # JWT filter, service, and security configuration
│   │       ├── tracking/           # GPS tracking functionality
│   │       ├── user/               # User management and settings
│   │       ├── util/               # Utility classes (distance, routing, geocoding)
│   │       ├── vehicle/            # Vehicle management
│   │       └── UniPoolBackendApplication.java
│   └── resources/
│       └── application.properties  # Application configuration
├── test/
│   └── java/
│       └── me/devziyad/unipoolbackend/
│           └── controller/         # Integration tests for all controllers
└── docs/
    └── API_DOCUMENTATION.md        # Complete API reference documentation
```

### Directory Descriptions

- **controller**: REST controllers handling HTTP requests and responses
- **service**: Service interfaces defining business logic contracts
- **service.impl**: Service implementations containing business logic
- **repository**: Spring Data JPA repositories for database operations
- **model**: Entity classes representing database tables (User, Ride, Booking, etc.)
- **common**: Enum classes for status types, roles, and payment methods
- **dto**: Data Transfer Objects for request and response payloads
- **security**: JWT authentication filter, JWT service, and Spring Security configuration
- **exception**: Custom exception classes and global exception handler
- **util**: Utility classes for distance calculations, routing, and geocoding
- **tests**: Comprehensive integration tests using MockMvc and JUnit 5

## Installation and Setup

### Requirements

- Java 17 or higher
- Maven 3.6 or higher
- Git (for cloning the repository)

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

### Configuration

The application configuration is located in `src/main/resources/application.properties`. Key configuration options include:

- **Database**: H2 in-memory database (configured by default)
- **Server Port**: 8080 (default)
- **JWT Secret**: Configured in application.properties
- **JWT Expiration**: 86400000 milliseconds (24 hours)
- **CORS**: Configured to allow all origins (adjust for production)
- **Platform Fee**: 10% (configurable)

To modify these settings, edit the `application.properties` file before running the application.

### Run the Application

Using Maven wrapper:

```bash
./mvnw spring-boot:run
```

Or using Maven directly:

```bash
mvn spring-boot:run
```

Or run the main class `UniPoolBackendApplication` from your IDE.

## Running the Application

### Using Maven Wrapper

```bash
./mvnw spring-boot:run
```

### Using IDE

1. Open the project in your IDE (IntelliJ IDEA, Eclipse, VS Code)
2. Locate `UniPoolBackendApplication.java`
3. Run the main method

### Expected Startup Logs

Upon successful startup, you should see logs indicating:

- Spring Boot application starting
- H2 database initialization
- JPA entity scanning
- Security configuration loading
- Server starting on port 8080

### Default Port

The application runs on port **8080** by default. The base URL is:

```
http://localhost:8080
```

API endpoints are available at:

```
http://localhost:8080/api
```

### H2 Console

The H2 database console is available at:

```
http://localhost:8080/h2-console
```

Default connection settings:
- JDBC URL: `jdbc:h2:mem:unipool`
- Username: `sa`
- Password: (empty)

## Running Tests

### Run All Tests

Using Maven wrapper:

```bash
./mvnw test
```

Or using Maven directly:

```bash
mvn test
```

### Test Suite Structure

The test suite is located in `src/test/java/me/devziyad/unipoolbackend/controller/` and includes:

- **AuthControllerTest**: Authentication and registration tests
- **UserControllerTest**: User management endpoint tests
- **VehicleControllerTest**: Vehicle CRUD operation tests
- **RideControllerTest**: Ride posting and search tests
- **BookingControllerTest**: Booking creation and management tests
- **PaymentControllerTest**: Payment processing tests
- **RatingControllerTest**: Rating submission tests
- **NotificationControllerTest**: Notification retrieval tests
- **LocationControllerTest**: Location management tests
- **GpsTrackingControllerTest**: GPS tracking functionality tests
- **AnalyticsControllerTest**: Analytics endpoint tests
- **AdminControllerTest**: Administrative endpoint tests
- **HealthControllerTest**: Health check endpoint tests

### Test Configuration

Tests use:
- **MockMvc**: For simulating HTTP requests and validating responses
- **ObjectMapper**: For JSON serialization and deserialization
- **JWT Service**: For generating test authentication tokens
- **H2 In-Memory Database**: For isolated test data
- **@AutoConfigureMockMvc**: For automatic MockMvc configuration
- **@Transactional**: For test data isolation

### Interpreting Test Results

- All tests should pass for a successful build
- Test output shows individual test execution status
- Failed tests display error messages and stack traces
- Test coverage includes both positive and negative test cases

## API Documentation

Complete API documentation is available in the project repository at:

**`docs/API_DOCUMENTATION.md`**

This documentation includes:

- All available endpoints with request and response examples
- Authentication requirements for each endpoint
- Request and response DTO structures
- Error codes and error response formats
- Status codes and their meanings
- Frontend integration guidelines
- Data model descriptions

### Using the API Documentation

1. Open `docs/API_DOCUMENTATION.md` in a Markdown viewer
2. Navigate to the relevant endpoint section
3. Review request examples and required fields
4. Implement API calls in your frontend application
5. Handle responses according to the documented structure

The API documentation is designed to be comprehensive and self-contained, providing all necessary information for frontend developers to integrate with the backend service.

## Contributing

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

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`

Example:

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

## License

This project is developed for academic purposes. License information will be added as needed.

## Contact

For academic inquiries or collaboration opportunities, please contact the development team through the appropriate university channels.

