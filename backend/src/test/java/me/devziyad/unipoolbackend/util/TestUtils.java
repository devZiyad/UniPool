package me.devziyad.unipoolbackend.util;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import me.devziyad.unipoolbackend.auth.dto.AuthResponse;
import me.devziyad.unipoolbackend.auth.dto.LoginRequest;
import me.devziyad.unipoolbackend.auth.dto.RegisterRequest;
import me.devziyad.unipoolbackend.booking.dto.CreateBookingRequest;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.location.dto.CreateLocationRequest;
import me.devziyad.unipoolbackend.location.dto.LocationResponse;
import me.devziyad.unipoolbackend.ride.dto.CreateRideRequest;
import me.devziyad.unipoolbackend.ride.dto.RideResponse;
import me.devziyad.unipoolbackend.route.dto.CreateRouteRequest;
import me.devziyad.unipoolbackend.route.dto.RouteResponse;
import me.devziyad.unipoolbackend.vehicle.dto.CreateVehicleRequest;
import me.devziyad.unipoolbackend.vehicle.dto.VehicleResponse;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Utility class for test helpers
 */
public class TestUtils {

    private static final ObjectMapper objectMapper = createObjectMapper();
    
    /**
     * Get the ObjectMapper instance for use in tests
     */
    public static ObjectMapper getObjectMapper() {
        return objectMapper;
    }
    
    private static ObjectMapper createObjectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        // Register JavaTimeModule for JSR310 date/time support
        mapper.registerModule(new JavaTimeModule());
        // Use ISO-8601 instead of timestamps
        mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        // Do not adjust dates based on JVM timezone
        mapper.disable(DeserializationFeature.ADJUST_DATES_TO_CONTEXT_TIME_ZONE);
        // Force UTC
        mapper.setTimeZone(java.util.TimeZone.getTimeZone("UTC"));
        return mapper;
    }
    
    private static final AtomicLong emailCounter = new AtomicLong(0);

    /**
     * Ensures password meets validation requirements (letter, number, special character)
     * If password doesn't meet requirements, appends "!" to make it valid
     */
    private static String ensureValidPassword(String password) {
        // Password must contain: letter, number, and special character (@$!%*?&#)
        // If password doesn't have special character, add one
        if (password != null && !password.matches(".*[@$!%*?&#].*")) {
            return password + "!";
        }
        return password;
    }

    /**
     * Creates a RegisterRequest for testing with unique email
     * Automatically ensures password meets validation requirements
     */
    public static RegisterRequest createRegisterRequest(String email, String password, String fullName, Role role) {
        RegisterRequest request = new RegisterRequest();
        long counter = emailCounter.incrementAndGet();
        request.setUniversityId("UNI" + System.currentTimeMillis() + "_" + counter);
        // Make email unique by appending counter
        String uniqueEmail = email.contains("@") 
            ? email.replace("@", "+" + counter + "@")
            : email + "+" + counter;
        request.setEmail(uniqueEmail);
        // Ensure password meets validation requirements
        request.setPassword(ensureValidPassword(password));
        request.setFullName(fullName);
        // Don't allow ADMIN role in registration - it will be rejected
        if (role != null && role != Role.ADMIN) {
            request.setRole(role.name());
        } else {
            request.setRole(Role.RIDER.name());
        }
        return request;
    }
    
    /**
     * Registration result containing token, email, and password that were actually used
     */
    public static class RegistrationResult {
        private final String token;
        private final String email;
        private final String password;
        
        public RegistrationResult(String token, String email, String password) {
            this.token = token;
            this.email = email;
            this.password = password;
        }
        
        public String getToken() {
            return token;
        }
        
        public String getEmail() {
            return email;
        }
        
        public String getPassword() {
            return password;
        }
    }

    /**
     * Creates a LoginRequest for testing
     */
    public static LoginRequest createLoginRequest(String email, String password) {
        LoginRequest request = new LoginRequest();
        request.setEmail(email);
        request.setPassword(password);
        return request;
    }

    /**
     * Registers a user and returns the auth token
     * Note: Email will be made unique automatically
     */
    public static String registerAndGetToken(RestTestClient restClient, String email, String password, String fullName, Role role) {
        RegistrationResult result = registerAndGetResult(restClient, email, password, fullName, role);
        return result.getToken();
    }
    
    /**
     * Registers a user and returns token, email, and password that were actually used
     */
    public static RegistrationResult registerAndGetResult(RestTestClient restClient, String email, String password, String fullName, Role role) {
        RegisterRequest registerRequest = createRegisterRequest(email, password, fullName, role);
        String actualEmail = registerRequest.getEmail();
        String actualPassword = registerRequest.getPassword(); // This is the password that was actually used (may have been modified)
        
        byte[] responseBytes = restClient
                .post()
                .uri("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .body(registerRequest)
                .exchange()
                .expectStatus()
                .isCreated()
                .expectBody()
                .returnResult()
                .getResponseBody();
        
        try {
            String responseBody = new String(responseBytes);
            AuthResponse authResponse = objectMapper.readValue(responseBody, AuthResponse.class);
            return new RegistrationResult(authResponse.getToken(), actualEmail, actualPassword);
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse auth response", e);
        }
    }

    /**
     * Logs in a user and returns the auth token
     */
    public static String loginAndGetToken(RestTestClient restClient, String email, String password) {
        LoginRequest loginRequest = createLoginRequest(email, password);
        
        byte[] responseBytes = restClient
                .post()
                .uri("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .body(loginRequest)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .returnResult()
                .getResponseBody();
        
        try {
            String responseBody = new String(responseBytes);
            AuthResponse authResponse = objectMapper.readValue(responseBody, AuthResponse.class);
            return authResponse.getToken();
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse auth response", e);
        }
    }

    /**
     * Creates headers with authorization token
     */
    public static Map<String, String> authHeaders(String token) {
        Map<String, String> headers = new HashMap<>();
        headers.put("Authorization", "Bearer " + token);
        return headers;
    }

    /**
     * Creates a vehicle for a driver
     */
    public static VehicleResponse createVehicle(RestTestClient restClient, String token) {
        CreateVehicleRequest request = new CreateVehicleRequest();
        request.setMake("Toyota");
        request.setModel("Camry");
        request.setColor("Blue");
        request.setPlateNumber("TEST" + System.currentTimeMillis());
        request.setSeatCount(4);
        request.setType(me.devziyad.unipoolbackend.common.VehicleType.SEDAN);

        byte[] responseBytes = restClient
                .post()
                .uri("/api/vehicles")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isCreated()
                .expectBody()
                .returnResult()
                .getResponseBody();

        try {
            String responseBody = new String(responseBytes);
            return objectMapper.readValue(responseBody, VehicleResponse.class);
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse vehicle response", e);
        }
    }

    /**
     * Creates a location
     */
    public static LocationResponse createLocation(RestTestClient restClient, String token, String label, double lat, double lon) {
        CreateLocationRequest request = new CreateLocationRequest();
        request.setLabel(label);
        request.setAddress("Test Address");
        request.setLatitude(lat);
        request.setLongitude(lon);
        request.setIsFavorite(false);

        byte[] responseBytes = restClient
                .post()
                .uri("/api/locations")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isCreated()
                .expectBody()
                .returnResult()
                .getResponseBody();

        try {
            String responseBody = new String(responseBytes);
            return objectMapper.readValue(responseBody, LocationResponse.class);
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse location response", e);
        }
    }

    /**
     * Helper method to get Instant now plus specified hours
     */
    public static Instant instantNowPlusHours(long hours) {
        return Instant.now().plus(hours, ChronoUnit.HOURS);
    }

    /**
     * Helper method to get Instant now plus specified minutes
     */
    public static Instant instantNowPlusMinutes(long minutes) {
        return Instant.now().plus(minutes, ChronoUnit.MINUTES);
    }

    /**
     * Helper method to get Instant now plus specified days
     */
    public static Instant instantNowPlusDays(long days) {
        return Instant.now().plus(days, ChronoUnit.DAYS);
    }

    /**
     * Creates a ride for a driver
     */
    public static RideResponse createRide(RestTestClient restClient, String driverToken, Long vehicleId, Long pickupLocationId, Long destinationLocationId) {
        return createRide(restClient, driverToken, vehicleId, pickupLocationId, destinationLocationId, 2);
    }

    /**
     * Creates a route for a driver
     */
    public static RouteResponse createRoute(RestTestClient restClient, String driverToken, double startLat, double startLon, double endLat, double endLon) {
        CreateRouteRequest request = new CreateRouteRequest();
        request.setStartLatitude(startLat);
        request.setStartLongitude(startLon);
        request.setEndLatitude(endLat);
        request.setEndLongitude(endLon);

        byte[] responseBytes = restClient
                .post()
                .uri("/api/locations/route")
                .header("Authorization", "Bearer " + driverToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isCreated()
                .expectBody()
                .returnResult()
                .getResponseBody();

        try {
            String responseBody = new String(responseBytes);
            return objectMapper.readValue(responseBody, RouteResponse.class);
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse route response", e);
        }
    }

    /**
     * Creates a ride for a driver with a custom hours offset for departure time
     * @param hoursOffset Hours from now for the departure time start (to avoid overlapping rides)
     */
    public static RideResponse createRide(RestTestClient restClient, String driverToken, Long vehicleId, Long pickupLocationId, Long destinationLocationId, long hoursOffset) {
        // First, get the location details to get coordinates
        LocationResponse pickupLocation = getLocation(restClient, driverToken, pickupLocationId);
        LocationResponse destinationLocation = getLocation(restClient, driverToken, destinationLocationId);
        
        // Create a route using the location coordinates
        RouteResponse route = createRoute(restClient, driverToken, 
                pickupLocation.getLatitude(), pickupLocation.getLongitude(),
                destinationLocation.getLatitude(), destinationLocation.getLongitude());
        
        // Now create the ride with the routeId
        CreateRideRequest request = new CreateRideRequest();
        request.setVehicleId(vehicleId);
        request.setPickupLocationId(pickupLocationId);
        request.setDestinationLocationId(destinationLocationId);
        request.setRouteId(route.getRouteId());
        Instant departureStart = instantNowPlusHours(hoursOffset);
        request.setDepartureTimeStart(departureStart);
        request.setDepartureTimeEnd(departureStart.plus(30, ChronoUnit.MINUTES));
        request.setTotalSeats(4);
        request.setBasePrice(new BigDecimal("10.00"));
        request.setPricePerSeat(new BigDecimal("2.50"));

        byte[] responseBytes = restClient
                .post()
                .uri("/api/rides")
                .header("Authorization", "Bearer " + driverToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isCreated()
                .expectBody()
                .returnResult()
                .getResponseBody();

        try {
            String responseBody = new String(responseBytes);
            return objectMapper.readValue(responseBody, RideResponse.class);
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse ride response", e);
        }
    }
    
    /**
     * Gets a location by ID
     */
    private static LocationResponse getLocation(RestTestClient restClient, String token, Long locationId) {
        byte[] responseBytes = restClient
                .get()
                .uri("/api/locations/" + locationId)
                .header("Authorization", "Bearer " + token)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .returnResult()
                .getResponseBody();

        try {
            String responseBody = new String(responseBytes);
            return objectMapper.readValue(responseBody, LocationResponse.class);
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse location response", e);
        }
    }

    /**
     * Creates a booking for a rider and returns the booking ID
     * This method requires fetching the ride details to get valid locations and times
     */
    public static Long createBooking(RestTestClient restClient, String riderToken, Long rideId, Integer seats) {
        // First, get the ride to extract valid locations and times
        // Use riderToken for authentication (any authenticated user can view rides)
        byte[] rideResponseBytes = restClient
                .get()
                .uri("/api/rides/" + rideId)
                .header("Authorization", "Bearer " + riderToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .returnResult()
                .getResponseBody();
        
        try {
            String rideResponseBody = new String(rideResponseBytes);
            @SuppressWarnings("unchecked")
            Map<String, Object> ride = objectMapper.readValue(rideResponseBody, Map.class);
            
            // Extract ride details
            Long pickupLocationId = Long.valueOf(ride.get("pickupLocationId").toString());
            Long dropoffLocationId = Long.valueOf(ride.get("destinationLocationId").toString());
            
            // Parse departure times from the ride
            String departureStartStr = ride.get("departureTimeStart").toString();
            String departureEndStr = ride.get("departureTimeEnd").toString();
            Instant departureStart = Instant.parse(departureStartStr);
            Instant departureEnd = Instant.parse(departureEndStr);
            
            // Set pickup times within the ride's departure time range
            // Use the start time and add 30 minutes for the end time
            Instant pickupTimeStart = departureStart;
            Instant pickupTimeEnd = departureStart.plus(30, ChronoUnit.MINUTES);
            
            // Ensure pickupTimeEnd doesn't exceed ride's departureTimeEnd
            if (pickupTimeEnd.isAfter(departureEnd)) {
                pickupTimeEnd = departureEnd;
            }
            
            // Create booking request with all required fields
            CreateBookingRequest request = new CreateBookingRequest();
            request.setRideId(rideId);
            request.setSeats(seats);
            request.setPickupLocationId(pickupLocationId);
            request.setDropoffLocationId(dropoffLocationId);
            request.setPickupTimeStart(pickupTimeStart);
            request.setPickupTimeEnd(pickupTimeEnd);

            // Create the booking (returns RideResponse)
            restClient
                    .post()
                    .uri("/api/bookings")
                    .header("Authorization", "Bearer " + riderToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(request)
                    .exchange()
                    .expectStatus()
                    .isCreated()
                    .expectBody()
                    .returnResult();

            // The booking creation endpoint returns a RideResponse, not BookingResponse
            // The bookings might not be included in the response due to lazy loading
            // Fetch the rider's bookings to get the newly created booking ID
            byte[] myBookingsResponseBytes = restClient
                    .get()
                    .uri("/api/bookings/me")
                    .header("Authorization", "Bearer " + riderToken)
                    .exchange()
                    .expectStatus()
                    .isOk()
                    .expectBody()
                    .returnResult()
                    .getResponseBody();
            
            String myBookingsResponseBody = new String(myBookingsResponseBytes);
            @SuppressWarnings("unchecked")
            java.util.List<Map<String, Object>> myBookings = objectMapper.readValue(myBookingsResponseBody, java.util.List.class);
            
            if (myBookings == null || myBookings.isEmpty()) {
                throw new RuntimeException("No bookings found for rider after creation");
            }
            
            // Find the booking for this ride (should be the most recent one)
            Map<String, Object> newBooking = null;
            for (Map<String, Object> booking : myBookings) {
                Object bookingRideIdObj = booking.get("rideId");
                if (bookingRideIdObj != null && Long.valueOf(bookingRideIdObj.toString()).equals(rideId)) {
                    newBooking = booking;
                    break;
                }
            }
            
            if (newBooking == null) {
                // If we can't find by rideId, use the first booking (most recent)
                newBooking = myBookings.get(0);
            }
            
            Object bookingIdObj = newBooking.get("bookingId");
            if (bookingIdObj == null) {
                bookingIdObj = newBooking.get("id"); // Fallback for compatibility
            }
            if (bookingIdObj == null) {
                throw new RuntimeException("Could not find bookingId in booking response");
            }
            return Long.valueOf(bookingIdObj.toString());
        } catch (Exception e) {
            throw new RuntimeException("Failed to create booking", e);
        }
    }

    /**
     * Creates an admin user directly in the database (bypasses registration restrictions)
     * Use this in test setup when you need an admin user for testing
     * 
     * @param userRepository UserRepository bean (inject in test class)
     * @param passwordEncoder PasswordEncoder bean (inject in test class)
     * @param email Email for the admin user
     * @param password Password (will be validated and fixed if needed)
     * @param fullName Full name for the admin user
     * @return The created User entity
     */
    public static me.devziyad.unipoolbackend.user.User createAdminUserDirectly(
            me.devziyad.unipoolbackend.user.UserRepository userRepository,
            org.springframework.security.crypto.password.PasswordEncoder passwordEncoder,
            String email,
            String password,
            String fullName) {
        
        // Ensure password meets requirements
        String validPassword = ensureValidPassword(password);
        
        // Make email unique
        long counter = emailCounter.incrementAndGet();
        String uniqueEmail = email.contains("@") 
            ? email.replace("@", "+" + counter + "@")
            : email + "+" + counter;
        
        me.devziyad.unipoolbackend.user.User admin = me.devziyad.unipoolbackend.user.User.builder()
                .universityId("ADMIN" + System.currentTimeMillis() + "_" + counter)
                .email(uniqueEmail)
                .passwordHash(passwordEncoder.encode(validPassword))
                .fullName(fullName)
                .role(Role.ADMIN)
                .enabled(true)
                .walletBalance(java.math.BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        
        return userRepository.save(admin);
    }

    /**
     * Creates an admin user and returns the login token
     * 
     * @param userRepository UserRepository bean (inject in test class)
     * @param passwordEncoder PasswordEncoder bean (inject in test class)
     * @param jwtService JwtService bean (inject in test class)
     * @param email Email for the admin user
     * @param password Password (will be validated and fixed if needed)
     * @param fullName Full name for the admin user
     * @return The auth token for the created admin user
     */
    public static String createAdminUserAndGetToken(
            me.devziyad.unipoolbackend.user.UserRepository userRepository,
            org.springframework.security.crypto.password.PasswordEncoder passwordEncoder,
            me.devziyad.unipoolbackend.security.JwtService jwtService,
            String email,
            String password,
            String fullName) {
        
        me.devziyad.unipoolbackend.user.User admin = createAdminUserDirectly(userRepository, passwordEncoder, email, password, fullName);
        return jwtService.generateToken(admin.getId(), admin.getEmail());
    }

    /**
     * Verifies a driver directly in the database (for test setup)
     * This bypasses the admin API and directly updates the user entity
     * 
     * @param userRepository UserRepository bean (inject in test class)
     * @param userId The ID of the user to verify as a driver
     */
    public static void verifyDriverDirectly(
            me.devziyad.unipoolbackend.user.UserRepository userRepository,
            Long userId) {
        me.devziyad.unipoolbackend.user.User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));
        user.setVerifiedDriver(true);
        userRepository.save(user);
    }

    /**
     * Verifies a driver by email directly in the database (for test setup)
     * This bypasses the admin API and directly updates the user entity
     * 
     * @param userRepository UserRepository bean (inject in test class)
     * @param email The email of the user to verify as a driver
     */
    public static void verifyDriverByEmailDirectly(
            me.devziyad.unipoolbackend.user.UserRepository userRepository,
            String email) {
        me.devziyad.unipoolbackend.user.User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
        user.setVerifiedDriver(true);
        userRepository.save(user);
    }

    /**
     * Verifies a user's university ID directly in the database (for test setup)
     * This bypasses the admin API and directly updates the user entity
     * 
     * @param userRepository UserRepository bean (inject in test class)
     * @param userId The ID of the user to verify
     */
    public static void verifyUniversityIdDirectly(
            me.devziyad.unipoolbackend.user.UserRepository userRepository,
            Long userId) {
        me.devziyad.unipoolbackend.user.User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));
        user.setUniversityIdVerified(true);
        userRepository.save(user);
    }

    /**
     * Verifies a user's university ID by email directly in the database (for test setup)
     * This bypasses the admin API and directly updates the user entity
     * 
     * @param userRepository UserRepository bean (inject in test class)
     * @param email The email of the user to verify
     */
    public static void verifyUniversityIdByEmailDirectly(
            me.devziyad.unipoolbackend.user.UserRepository userRepository,
            String email) {
        me.devziyad.unipoolbackend.user.User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
        user.setUniversityIdVerified(true);
        userRepository.save(user);
    }
}

