# Test Database Configuration

## Overview

Tests use a completely isolated in-memory H2 database that is separate from the main development/production database. This ensures:

1. **Complete Isolation**: Tests never touch the main database
2. **Automatic Reset**: Database schema and data are automatically dropped and recreated for each test run
3. **Fast Execution**: In-memory database is faster than file-based databases
4. **Clean State**: Each test starts with a fresh, empty database

## Configuration

The test configuration is defined in `application-test.properties`:

- **Database**: In-memory H2 (`jdbc:h2:mem:testdb`)
- **DDL Mode**: `create-drop` - schema is created at test start and dropped at test end
- **Profile**: All test classes use `@ActiveProfiles("test")` to activate this configuration

## How It Works

1. When tests run, Spring Boot activates the `test` profile
2. The test configuration loads `application-test.properties`
3. An in-memory H2 database is created
4. Hibernate creates all tables from entity definitions (`ddl-auto=create-drop`)
5. Tests execute with a clean database
6. After tests complete, the database is automatically dropped

## Test Data

Tests create their own data using `TestUtils` helper methods:
- Users are registered via the API
- Vehicles, locations, rides, and bookings are created as needed
- No pre-existing data is assumed

## Running Tests

```bash
# Run all tests
./mvnw test

# Run specific test class
./mvnw test -Dtest=AdminControllerIT

# Run with verbose output
./mvnw test -Dtest=AdminControllerIT -X
```

## Important Notes

- **No Admin Initialization**: The test profile disables default admin account creation (empty admin config values)
- **Rate Limiting Disabled**: Rate limiting is disabled in tests for faster execution
- **Random Port**: Server runs on random port (0) to avoid conflicts
- **Reduced Logging**: Test logging is set to WARN level to reduce noise

## Database Isolation

The main database (`./data/unipool.mv.db`) is **never** touched by tests. The test database exists only in memory during test execution and is completely destroyed afterward.

