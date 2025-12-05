package me.devziyad.unipoolbackend.user;

import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.user.dto.ChangePasswordRequest;
import me.devziyad.unipoolbackend.user.dto.UpdateUserRequest;
import me.devziyad.unipoolbackend.util.TestUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

@AutoConfigureRestTestClient
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class UserControllerIT {

    @Autowired
    private RestTestClient restClient;

    private String userToken;

    @BeforeEach
    void setUp() {
        // Create user
        userToken = TestUtils.registerAndGetToken(
                restClient,
                "user@example.com",
                "password123",
                "Test User",
                Role.RIDER
        );
    }

    @Test
    void shouldGetCurrentUser() {
        restClient
                .get()
                .uri("/api/users/me")
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$.id").exists()
                .jsonPath("$.email").isEqualTo("user@example.com")
                .jsonPath("$.fullName").isEqualTo("Test User");
    }

    @Test
    void shouldRejectGetCurrentUserWithoutAuth() {
        restClient
                .get()
                .uri("/api/users/me")
                .exchange()
                .expectStatus()
                .isUnauthorized();
    }

    @Test
    void shouldGetUserById() {
        restClient
                .get()
                .uri("/api/users/1")
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.id").exists()
                .jsonPath("$.email").exists();
    }

    @Test
    void shouldUpdateCurrentUser() {
        UpdateUserRequest request = new UpdateUserRequest();
        request.setFullName("Updated Name");
        request.setPhoneNumber("1234567890");

        restClient
                .put()
                .uri("/api/users/me")
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.fullName").isEqualTo("Updated Name")
                .jsonPath("$.phoneNumber").isEqualTo("1234567890");
    }

    @Test
    void shouldRejectUpdateCurrentUserWithoutAuth() {
        UpdateUserRequest request = new UpdateUserRequest();
        request.setFullName("Updated Name");

        restClient
                .put()
                .uri("/api/users/me")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isUnauthorized();
    }

    @Test
    void shouldChangePassword() {
        ChangePasswordRequest request = new ChangePasswordRequest();
        request.setOldPassword("password123");
        request.setNewPassword("newpassword123");

        restClient
                .put()
                .uri("/api/users/me/password")
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isOk();
    }

    @Test
    void shouldUpdateRole() {
        UserController.UpdateRoleRequest request = new UserController.UpdateRoleRequest();
        request.setRole("BOTH");

        restClient
                .put()
                .uri("/api/users/me/role")
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.role").exists();
    }

    @Test
    void shouldGetUserSettings() {
        restClient
                .get()
                .uri("/api/users/me/settings")
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$").exists();
    }

    @Test
    void shouldGetUserStats() {
        restClient
                .get()
                .uri("/api/users/me/stats")
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$").exists();
    }

    @Test
    void shouldRejectInvalidUpdateUserRequest() {
        UpdateUserRequest request = new UpdateUserRequest();
        // Missing required fullName field

        restClient
                .put()
                .uri("/api/users/me")
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isBadRequest();
    }
}

