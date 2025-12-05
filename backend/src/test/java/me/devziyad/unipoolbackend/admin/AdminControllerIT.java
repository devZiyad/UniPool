package me.devziyad.unipoolbackend.admin;

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
public class AdminControllerIT {

    @Autowired
    private RestTestClient restClient;

    private String adminToken;
    private String regularUserToken;
    private Long rideId;

    @BeforeEach
    void setUp() {
        // Create admin user
        adminToken = TestUtils.registerAndGetToken(
                restClient,
                "admin@example.com",
                "admin123",
                "Admin User",
                Role.ADMIN
        );

        // Create regular user
        regularUserToken = TestUtils.registerAndGetToken(
                restClient,
                "user@example.com",
                "user123",
                "Regular User",
                Role.RIDER
        );

        // Create a driver user for creating rides
        String driverToken = TestUtils.registerAndGetToken(
                restClient,
                "driver@example.com",
                "driver123",
                "Driver User",
                Role.DRIVER
        );

        // Create vehicle, locations, and ride for admin tests
        VehicleResponse vehicle = TestUtils.createVehicle(restClient, driverToken);
        LocationResponse pickupLocation = TestUtils.createLocation(restClient, driverToken, "Pickup", 40.7128, -74.0060);
        LocationResponse destinationLocation = TestUtils.createLocation(restClient, driverToken, "Destination", 40.7589, -73.9851);
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
    void shouldGetAllUsersAsAdmin() {
        restClient
                .get()
                .uri("/api/admin/users")
                .header("Authorization", "Bearer " + adminToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$").isArray()
                .jsonPath("$[0].id").exists();
    }

    @Test
    void shouldRejectGetAllUsersAsNonAdmin() {
        restClient
                .get()
                .uri("/api/admin/users")
                .header("Authorization", "Bearer " + regularUserToken)
                .exchange()
                .expectStatus()
                .isForbidden();
    }

    @Test
    void shouldGetUserByIdAsAdmin() {
        // Test with ID 1 (assuming at least one user exists from setup)
        restClient
                .get()
                .uri("/api/admin/users/1")
                .header("Authorization", "Bearer " + adminToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.id").exists()
                .jsonPath("$.email").exists();
    }

    @Test
    void shouldEnableUserAsAdmin() {
        AdminController.EnableUserRequest request = new AdminController.EnableUserRequest();
        request.setEnabled(true);

        restClient
                .put()
                .uri("/api/admin/users/1/enable")
                .header("Authorization", "Bearer " + adminToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.enabled").isEqualTo(true);
    }

    @Test
    void shouldGetAllRidesAsAdmin() {
        restClient
                .get()
                .uri("/api/admin/rides")
                .header("Authorization", "Bearer " + adminToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$").isArray();
    }

    @Test
    void shouldGetRideByIdAsAdmin() {
        // Get the ride we created in setUp
        restClient
                .get()
                .uri("/api/admin/rides/" + rideId)
                .header("Authorization", "Bearer " + adminToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(rideId.intValue())
                .jsonPath("$.driverId").exists();
    }

    @Test
    void shouldGetAllBookingsAsAdmin() {
        restClient
                .get()
                .uri("/api/admin/bookings")
                .header("Authorization", "Bearer " + adminToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$").isArray();
    }

    @Test
    void shouldGetAllPaymentsAsAdmin() {
        restClient
                .get()
                .uri("/api/admin/payments")
                .header("Authorization", "Bearer " + adminToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$").isArray();
    }

    @Test
    void shouldRejectAdminEndpointsWithoutAuth() {
        // Spring Security returns 403 Forbidden when no authentication token is provided
        // (401 Unauthorized is typically for invalid/expired tokens)
        restClient
                .get()
                .uri("/api/admin/users")
                .exchange()
                .expectStatus()
                .isForbidden();
    }
}

