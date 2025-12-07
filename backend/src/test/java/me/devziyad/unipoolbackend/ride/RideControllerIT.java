package me.devziyad.unipoolbackend.ride;

import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.ride.dto.CreateRideRequest;
import me.devziyad.unipoolbackend.util.TestUtils;

import static me.devziyad.unipoolbackend.util.TestUtils.instantNowPlusHours;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

@AutoConfigureRestTestClient
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@org.springframework.test.context.ActiveProfiles("test")
public class RideControllerIT {

    @Autowired
    private RestTestClient restClient;

    private String driverToken;
    private Long vehicleId;
    private Long pickupLocationId;
    private Long destinationLocationId;
    private Long rideId;

    @BeforeEach
    void setUp() {
        // Create driver user
        driverToken = TestUtils.registerAndGetToken(
                restClient,
                "driver@example.com",
                "driver123",
                "Driver User",
                Role.DRIVER
        );
        
        // Create vehicle and locations for tests
        me.devziyad.unipoolbackend.vehicle.dto.VehicleResponse vehicle = TestUtils.createVehicle(restClient, driverToken);
        vehicleId = vehicle.getId();
        
        me.devziyad.unipoolbackend.location.dto.LocationResponse pickupLocation = TestUtils.createLocation(restClient, driverToken, "Pickup", 40.7128, -74.0060);
        pickupLocationId = pickupLocation.getId();
        
        me.devziyad.unipoolbackend.location.dto.LocationResponse destinationLocation = TestUtils.createLocation(restClient, driverToken, "Destination", 40.7589, -73.9851);
        destinationLocationId = destinationLocation.getId();
        
        // Create a ride for tests that need it
        me.devziyad.unipoolbackend.ride.dto.RideResponse ride = TestUtils.createRide(
                restClient,
                driverToken,
                vehicleId,
                pickupLocationId,
                destinationLocationId
        );
        rideId = ride.getRideId();
    }

    @Test
    void shouldCreateRideAsDriver() {
        CreateRideRequest request = new CreateRideRequest();
        request.setVehicleId(vehicleId);
        request.setPickupLocationId(pickupLocationId);
        request.setDestinationLocationId(destinationLocationId);
        // Use a time that doesn't overlap with the ride created in setUp
        // setUp creates a ride starting at instantNowPlusHours(2), so we'll use instantNowPlusHours(25)
        // to ensure no overlap (since rides can be up to 24 hours long)
        Instant departureStart = instantNowPlusHours(25);
        request.setDepartureTimeStart(departureStart);
        request.setDepartureTimeEnd(departureStart.plus(30, ChronoUnit.MINUTES));
        request.setTotalSeats(4);
        request.setBasePrice(new BigDecimal("10.00"));
        request.setPricePerSeat(new BigDecimal("5.00"));

        restClient
                .post()
                .uri("/api/rides")
                .header("Authorization", "Bearer " + driverToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isCreated()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$.rideId").exists()
                .jsonPath("$.driverId").exists()
                .jsonPath("$.totalSeats").isEqualTo(4);
    }

    @Test
    void shouldRejectCreateRideWithoutAuth() {
        CreateRideRequest request = new CreateRideRequest();
        request.setVehicleId(vehicleId);
        request.setPickupLocationId(pickupLocationId);
        request.setDestinationLocationId(destinationLocationId);
        Instant departureStart = instantNowPlusHours(2);
        request.setDepartureTimeStart(departureStart);
        request.setDepartureTimeEnd(departureStart.plus(30, ChronoUnit.MINUTES));
        request.setTotalSeats(4);

        // Spring Security returns 403 FORBIDDEN when no authentication token is provided
        restClient
                .post()
                .uri("/api/rides")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isForbidden();
    }

    @Test
    void shouldGetRideById() {
        // Test with the ride we created in setup
        // Note: This endpoint may require authentication depending on security config
        restClient
                .get()
                .uri("/api/rides/" + rideId)
                .header("Authorization", "Bearer " + driverToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.rideId").isEqualTo(rideId.intValue())
                .jsonPath("$.driverId").exists();
    }

    @Test
    void shouldGetMyRidesAsDriver() {
        restClient
                .get()
                .uri("/api/rides/me/driver")
                .header("Authorization", "Bearer " + driverToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$").isArray();
    }

    @Test
    void shouldUpdateRideStatus() {
        RideController.UpdateStatusRequest request = new RideController.UpdateStatusRequest();
        request.setStatus(RideStatus.IN_PROGRESS);

        restClient
                .patch()
                .uri("/api/rides/" + rideId + "/status")
                .header("Authorization", "Bearer " + driverToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.status").isEqualTo("IN_PROGRESS");
    }

    @Test
    void shouldGetAvailableSeats() {
        // This endpoint requires authentication per API documentation
        restClient
                .get()
                .uri("/api/rides/" + rideId + "/available-seats")
                .header("Authorization", "Bearer " + driverToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$").isNumber()
                .jsonPath("$").isEqualTo(4); // We created ride with 4 total seats, no bookings yet
    }

    @Test
    void shouldRejectUpdateRideWithoutAuth() {
        RideController.UpdateStatusRequest request = new RideController.UpdateStatusRequest();
        request.setStatus(RideStatus.IN_PROGRESS);

        // Spring Security returns 403 FORBIDDEN when no authentication token is provided
        restClient
                .patch()
                .uri("/api/rides/" + rideId + "/status")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isForbidden();
    }
}

