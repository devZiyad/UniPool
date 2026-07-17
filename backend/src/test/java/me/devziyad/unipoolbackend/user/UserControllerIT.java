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
@org.springframework.test.context.ActiveProfiles("test")
public class UserControllerIT {

    @Autowired
    private RestTestClient restClient;

    private String userToken;
    private Long userId;
    private String userEmail;

    @BeforeEach
    void setUp() {
        // Create user and get their ID
        TestUtils.RegistrationResult userResult = TestUtils.registerAndGetResult(
                restClient,
                "user@example.com",
                "password123",
                "Test User",
                Role.RIDER
        );
        userToken = userResult.getToken();
        userEmail = userResult.getEmail(); // Store the actual email (may have been made unique)
        
        // Get user ID
        byte[] userResponseBytes = restClient
                .get()
                .uri("/api/auth/me")
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .returnResult()
                .getResponseBody();
        try {
            String userResponseBody = new String(userResponseBytes);
            @SuppressWarnings("unchecked")
            java.util.Map<String, Object> user = TestUtils.getObjectMapper().readValue(userResponseBody, java.util.Map.class);
            userId = Long.valueOf(user.get("id").toString());
        } catch (Exception e) {
            throw new RuntimeException("Failed to get user ID", e);
        }
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
                .jsonPath("$.email").isEqualTo(userEmail) // Use the actual email from registration
                .jsonPath("$.fullName").isEqualTo("Test User");
    }

    @Test
    void shouldRejectGetCurrentUserWithoutAuth() {
        // Spring Security returns 403 FORBIDDEN when no authentication token is provided
        restClient
                .get()
                .uri("/api/users/me")
                .exchange()
                .expectStatus()
                .isForbidden();
    }

    @Test
    void shouldGetUserById() {
        // This endpoint requires authentication per security config
        restClient
                .get()
                .uri("/api/users/" + userId)
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.id").isEqualTo(userId.intValue())
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

        // Spring Security returns 403 FORBIDDEN when no authentication token is provided
        restClient
                .put()
                .uri("/api/users/me")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isForbidden();
    }

    @Test
    void shouldChangePassword() {
        ChangePasswordRequest request = new ChangePasswordRequest();
        request.setOldPassword("password123!"); // Password was auto-fixed during registration
        request.setNewPassword("newpassword123!"); // Must include special character

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

