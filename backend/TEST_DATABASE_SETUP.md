# Test Database Setup

## Overview

The test suite uses a **completely isolated in-memory H2 database** that is separate from the main development/production database. This ensures tests never interfere with your actual data.

## Key Features

✅ **Complete Isolation**: Tests use `jdbc:h2:mem:testdb` (in-memory) vs main database `jdbc:h2:file:./data/unipool`  
✅ **Automatic Reset**: Schema is created at test start and dropped at test end (`ddl-auto=create-drop`)  
✅ **No Data Pollution**: Main database (`./data/unipool.mv.db`) is never touched by tests  
✅ **Fast Execution**: In-memory database is faster than file-based  
✅ **Clean State**: Each test run starts with a fresh, empty database  

## Configuration Files

### Main Application Config
- **File**: `src/main/resources/application.properties`
- **Database**: `jdbc:h2:file:./data/unipool` (file-based, persistent)
- **DDL Mode**: `update` (preserves data)

### Test Application Config
- **File**: `src/test/resources/application-test.properties`
- **Database**: `jdbc:h2:mem:testdb` (in-memory, temporary)
- **DDL Mode**: `create-drop` (drops everything after tests)

## How It Works

1. **Test Profile Activation**: All integration tests use `@ActiveProfiles("test")`
2. **Configuration Loading**: Spring Boot loads `application-test.properties` when test profile is active
3. **Database Creation**: In-memory H2 database is created automatically
4. **Schema Creation**: Hibernate creates all tables from entity definitions
5. **Test Execution**: Tests run with a clean database
6. **Cleanup**: Database is automatically dropped when tests complete

## Test Classes Using Test Database

All integration tests (`*IT.java`) use the test profile:

- `HealthControllerIT`
- `AdminControllerIT`
- `AuthControllerIT`
- `BookingControllerIT`
- `RideControllerIT`
- `UserControllerIT`
- `PaymentControllerIT`

## Test Data Management

Tests create their own data using `TestUtils` helper methods:
- Users are registered via API endpoints
- Vehicles, locations, rides, and bookings are created as needed
- No pre-existing data is assumed or required

## Running Tests

```bash
# Run all tests (uses test database automatically)
./mvnw test

# Run specific test class
./mvnw test -Dtest=AdminControllerIT

# Run with verbose output
./mvnw test -Dtest=AdminControllerIT -X

# Skip tests
./mvnw clean install -DskipTests
```

## Test Configuration Details

### Database Settings
- **Type**: In-memory H2
- **URL**: `jdbc:h2:mem:testdb`
- **Mode**: PostgreSQL compatibility mode
- **Connection**: Single connection per test run

### JPA/Hibernate Settings
- **DDL Auto**: `create-drop` (creates on start, drops on end)
- **Show SQL**: Disabled (set to `true` in config if needed for debugging)
- **Timezone**: UTC (matches production)

### Other Test Settings
- **Admin Initialization**: Disabled (empty admin config values)
- **Rate Limiting**: Disabled for faster test execution
- **Server Port**: Random (0) to avoid conflicts
- **Logging**: WARN level to reduce noise

## Verification

To verify tests are using the test database:

1. Check test logs - should see H2 in-memory database connection
2. Check main database file - `./data/unipool.mv.db` should not be modified during test runs
3. Run tests multiple times - each run should start with empty database

## Troubleshooting

### Tests are slow
- Check if rate limiting is disabled in test config
- Verify logging level is set to WARN
- Ensure in-memory database is being used (not file-based)

### Tests fail with "table not found"
- Verify `ddl-auto=create-drop` in test config
- Check that test profile is active (`@ActiveProfiles("test")`)
- Ensure entities are properly annotated with `@Entity`

### Tests affect main database
- Verify test config uses `jdbc:h2:mem:testdb` (not `file:./data/unipool`)
- Check that `@ActiveProfiles("test")` is on all integration tests
- Ensure test profile is not accidentally used in production

## Best Practices

1. **Always use TestUtils**: Create test data via helper methods, not direct database access
2. **Isolated Tests**: Each test should be independent and not rely on other tests
3. **Clean Setup**: Use `@BeforeEach` to set up test data, not `@BeforeAll`
4. **No Hardcoded IDs**: Always use IDs from created entities, never assume ID=1 exists
5. **Verify Isolation**: Regularly check that main database is not modified during tests

