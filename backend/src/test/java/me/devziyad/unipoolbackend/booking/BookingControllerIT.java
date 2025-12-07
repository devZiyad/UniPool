package me.devziyad.unipoolbackend.booking;

import me.devziyad.unipoolbackend.booking.dto.CreateBookingRequest;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.location.dto.LocationResponse;
import me.devziyad.unipoolbackend.ride.dto.RideResponse;
import me.devziyad.unipoolbackend.util.TestUtils;
import me.devziyad.unipoolbackend.vehicle.dto.VehicleResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

@AutoConfigureRestTestClient
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@org.springframework.test.context.ActiveProfiles("test")
public class BookingControllerIT {

    @Autowired
    private RestTestClient restClient;

    private String riderToken;
    private String driverToken;
    private Long rideId;

    @BeforeEach
    void setUp() {
        // Create rider user
        riderToken = TestUtils.registerAndGetToken(
                restClient,
                "rider@example.com",
                "rider123",
                "Rider User",
                Role.RIDER
        );

        // Create driver user
        driverToken = TestUtils.registerAndGetToken(
                restClient,
                "driver@example.com",
                "driver123",
                "Driver User",
                Role.DRIVER
        );

        // Create vehicle for driver
        VehicleResponse vehicle = TestUtils.createVehicle(restClient, driverToken);

        // Create locations
        LocationResponse pickupLocation = TestUtils.createLocation(restClient, driverToken, "Pickup", 40.7128, -74.0060);
        LocationResponse destinationLocation = TestUtils.createLocation(restClient, driverToken, "Destination", 40.7589, -73.9851);

        // Create a ride
        RideResponse ride = TestUtils.createRide(
                restClient,
                driverToken,
                vehicle.getId(),
                pickupLocation.getId(),
                destinationLocation.getId()
        );
        rideId = ride.getRideId();
    }

    @Test
    void shouldCreateBookingAsRider() {
        // Get ride details to extract valid locations and times
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
            java.util.Map<String, Object> ride = TestUtils.getObjectMapper().readValue(rideResponseBody, java.util.Map.class);
            
            Long pickupLocationId = Long.valueOf(ride.get("pickupLocationId").toString());
            Long dropoffLocationId = Long.valueOf(ride.get("destinationLocationId").toString());
            java.time.Instant departureStart = java.time.Instant.parse(ride.get("departureTimeStart").toString());
            java.time.Instant departureEnd = java.time.Instant.parse(ride.get("departureTimeEnd").toString());
            
            // Set pickup times within the ride's departure time range
            java.time.Instant pickupTimeStart = departureStart;
            java.time.Instant pickupTimeEnd = departureStart.plus(30, java.time.temporal.ChronoUnit.MINUTES);
            if (pickupTimeEnd.isAfter(departureEnd)) {
                pickupTimeEnd = departureEnd;
            }
            
            CreateBookingRequest request = new CreateBookingRequest();
            request.setRideId(rideId);
            request.setSeats(2);
            request.setPickupLocationId(pickupLocationId);
            request.setDropoffLocationId(dropoffLocationId);
            request.setPickupTimeStart(pickupTimeStart);
            request.setPickupTimeEnd(pickupTimeEnd);

            restClient
                    .post()
                    .uri("/api/bookings")
                    .header("Authorization", "Bearer " + riderToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(request)
                    .exchange()
                    .expectStatus()
                    .isCreated()
                    .expectHeader()
                    .contentType(MediaType.APPLICATION_JSON)
                    .expectBody()
                    .jsonPath("$.rideId").isEqualTo(rideId.intValue())
                    .jsonPath("$.availableSeats").exists();
        } catch (Exception e) {
            throw new RuntimeException("Failed to create booking request", e);
        }
    }

    @Test
    void shouldRejectCreateBookingWithoutAuth() {
        CreateBookingRequest request = new CreateBookingRequest();
        request.setRideId(1L);
        request.setSeats(2);

        // Spring Security returns 403 Forbidden when no authentication token is provided
        restClient
                .post()
                .uri("/api/bookings")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isForbidden();
    }

    @Test
    void shouldGetBookingById() {
        // First create a booking
        Long bookingId = TestUtils.createBooking(restClient, riderToken, rideId, 2);

        // Then get it (must include Authorization header)
        restClient
                .get()
                .uri("/api/bookings/" + bookingId)
                .header("Authorization", "Bearer " + riderToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.bookingId").isEqualTo(bookingId.intValue())
                .jsonPath("$.rideId").isEqualTo(rideId.intValue());
    }

    @Test
    void shouldGetMyBookingsAsRider() {
        restClient
                .get()
                .uri("/api/bookings/me")
                .header("Authorization", "Bearer " + riderToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$").isArray();
    }

    @Test
    void shouldGetBookingsForRideAsDriver() {
        // First create a booking
        TestUtils.createBooking(restClient, riderToken, rideId, 2);

        // Then get bookings for the ride
        restClient
                .get()
                .uri("/api/bookings/ride/" + rideId)
                .header("Authorization", "Bearer " + driverToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$").isArray()
                .jsonPath("$[0].rideId").isEqualTo(rideId.intValue());
    }

    @Test
    void shouldCancelBooking() {
        // First create a booking
        Long bookingId = TestUtils.createBooking(restClient, riderToken, rideId, 2);

        // Then cancel it
        restClient
                .post()
                .uri("/api/bookings/" + bookingId + "/cancel")
                .header("Authorization", "Bearer " + riderToken)
                .exchange()
                .expectStatus()
                .isOk();
    }

    @Test
    void shouldRejectCancelBookingWithoutAuth() {
        // Spring Security returns 403 Forbidden when no authentication token is provided
        restClient
                .post()
                .uri("/api/bookings/1/cancel")
                .exchange()
                .expectStatus()
                .isForbidden();
    }

    @Test
    void shouldRejectInvalidBookingRequest() {
        CreateBookingRequest request = new CreateBookingRequest();
        // Missing required fields
        request.setRideId(null);
        request.setSeats(null);

        restClient
                .post()
                .uri("/api/bookings")
                .header("Authorization", "Bearer " + riderToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isBadRequest();
    }
}

