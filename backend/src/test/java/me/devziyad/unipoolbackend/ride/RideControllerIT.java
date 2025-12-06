package me.devziyad.unipoolbackend.ride;

import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.ride.dto.CreateRideRequest;
import me.devziyad.unipoolbackend.util.TestUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@AutoConfigureRestTestClient
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class RideControllerIT {

    @Autowired
    private RestTestClient restClient;

    private String driverToken;

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
    }

    @Test
    void shouldCreateRideAsDriver() {
        CreateRideRequest request = new CreateRideRequest();
        request.setVehicleId(1L);
        request.setPickupLocationId(1L);
        request.setDestinationLocationId(2L);
        LocalDateTime departureStart = LocalDateTime.now().plusHours(2);
        request.setDepartureTimeStart(departureStart);
        request.setDepartureTimeEnd(departureStart.plusMinutes(30));
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
        request.setVehicleId(1L);
        request.setPickupLocationId(1L);
        request.setDestinationLocationId(2L);
        LocalDateTime departureStart = LocalDateTime.now().plusHours(2);
        request.setDepartureTimeStart(departureStart);
        request.setDepartureTimeEnd(departureStart.plusMinutes(30));
        request.setTotalSeats(4);

        restClient
                .post()
                .uri("/api/rides")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isUnauthorized();
    }

    @Test
    void shouldGetRideById() {
        // Test with ID 1 (assuming at least one ride exists)
        restClient
                .get()
                .uri("/api/rides/1")
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.rideId").exists();
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
                .uri("/api/rides/1/status")
                .header("Authorization", "Bearer " + driverToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.status").exists();
    }

    @Test
    void shouldGetAvailableSeats() {
        restClient
                .get()
                .uri("/api/rides/1/available-seats")
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$").isNumber();
    }

    @Test
    void shouldRejectUpdateRideWithoutAuth() {
        RideController.UpdateStatusRequest request = new RideController.UpdateStatusRequest();
        request.setStatus(RideStatus.IN_PROGRESS);

        restClient
                .patch()
                .uri("/api/rides/1/status")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isUnauthorized();
    }
}

