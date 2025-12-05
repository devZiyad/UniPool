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
        rideId = ride.getId();
    }

    @Test
    void shouldCreateBookingAsRider() {
        CreateBookingRequest request = new CreateBookingRequest();
        request.setRideId(rideId);
        request.setSeats(2);

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
                .jsonPath("$.id").exists()
                .jsonPath("$.rideId").isEqualTo(rideId.intValue())
                .jsonPath("$.seats").isEqualTo(2);
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

        // Then get it
        restClient
                .get()
                .uri("/api/bookings/" + bookingId)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(bookingId.intValue())
                .jsonPath("$.rideId").exists();
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

