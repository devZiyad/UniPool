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
     * Creates a RegisterRequest for testing with unique email
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
        request.setPassword(password);
        request.setFullName(fullName);
        request.setRole(role != null ? role.name() : Role.RIDER.name());
        return request;
    }
    
    /**
     * Registration result containing token and the actual email used
     */
    public static class RegistrationResult {
        private final String token;
        private final String email;
        
        public RegistrationResult(String token, String email) {
            this.token = token;
            this.email = email;
        }
        
        public String getToken() {
            return token;
        }
        
        public String getEmail() {
            return email;
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
     * Registers a user and returns both token and the actual email used
     */
    public static RegistrationResult registerAndGetResult(RestTestClient restClient, String email, String password, String fullName, Role role) {
        RegisterRequest registerRequest = createRegisterRequest(email, password, fullName, role);
        String actualEmail = registerRequest.getEmail();
        
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
            return new RegistrationResult(authResponse.getToken(), actualEmail);
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
        CreateRideRequest request = new CreateRideRequest();
        request.setVehicleId(vehicleId);
        request.setPickupLocationId(pickupLocationId);
        request.setDestinationLocationId(destinationLocationId);
        Instant departureStart = instantNowPlusHours(2);
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
     * Creates a booking for a rider and returns the booking ID
     */
    public static Long createBooking(RestTestClient restClient, String riderToken, Long rideId, Integer seats) {
        CreateBookingRequest request = new CreateBookingRequest();
        request.setRideId(rideId);
        request.setSeats(seats);

        byte[] responseBytes = restClient
                .post()
                .uri("/api/bookings")
                .header("Authorization", "Bearer " + riderToken)
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
            @SuppressWarnings("unchecked")
            Map<String, Object> booking = objectMapper.readValue(responseBody, Map.class);
            return Long.valueOf(booking.get("id").toString());
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse booking response", e);
        }
    }
}

