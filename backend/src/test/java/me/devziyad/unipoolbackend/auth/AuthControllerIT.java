package me.devziyad.unipoolbackend.auth;

import me.devziyad.unipoolbackend.auth.dto.LoginRequest;
import me.devziyad.unipoolbackend.auth.dto.RegisterRequest;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.util.TestUtils;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

@AutoConfigureRestTestClient
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class AuthControllerIT {

    @Autowired
    private RestTestClient restClient;

    @Test
    void shouldRegisterNewUser() {
        RegisterRequest request = TestUtils.createRegisterRequest(
                "test@example.com",
                "password123",
                "Test User",
                Role.RIDER
        );
        String expectedEmail = request.getEmail(); // Get the unique email that will be used

        restClient
                .post()
                .uri("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isCreated()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$.token").exists()
                .jsonPath("$.user").exists()
                .jsonPath("$.user.email").isEqualTo(expectedEmail)
                .jsonPath("$.user.fullName").isEqualTo("Test User");
    }

    @Test
    void shouldRejectInvalidEmailOnRegister() {
        RegisterRequest request = TestUtils.createRegisterRequest(
                "invalid-email",
                "password123",
                "Test User",
                Role.RIDER
        );
        request.setEmail("invalid-email");

        restClient
                .post()
                .uri("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isBadRequest();
    }

    @Test
    void shouldLoginWithValidCredentials() {
        // First register a user and get the actual email used
        TestUtils.RegistrationResult registration = TestUtils.registerAndGetResult(
                restClient,
                "login@example.com",
                "password123",
                "Login User",
                Role.RIDER
        );

        // Then login with the actual email that was registered
        LoginRequest loginRequest = TestUtils.createLoginRequest(
                registration.getEmail(),
                "password123"
        );

        restClient
                .post()
                .uri("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .body(loginRequest)
                .exchange()
                .expectStatus()
                .isOk()
                .expectHeader()
                .contentType(MediaType.APPLICATION_JSON)
                .expectBody()
                .jsonPath("$.token").exists()
                .jsonPath("$.user").exists()
                .jsonPath("$.user.email").isEqualTo(registration.getEmail());
    }

    @Test
    void shouldRejectInvalidCredentials() {
        LoginRequest loginRequest = TestUtils.createLoginRequest(
                "nonexistent@example.com",
                "wrongpassword"
        );

        restClient
                .post()
                .uri("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .body(loginRequest)
                .exchange()
                .expectStatus()
                .isUnauthorized();
    }

    @Test
    void shouldGetCurrentUserWithValidToken() {
        // Register and get token with actual email used
        TestUtils.RegistrationResult registration = TestUtils.registerAndGetResult(
                restClient,
                "current@example.com",
                "password123",
                "Current User",
                Role.RIDER
        );

        // Get current user
        restClient
                .get()
                .uri("/api/auth/me")
                .header("Authorization", "Bearer " + registration.getToken())
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .jsonPath("$.email").isEqualTo(registration.getEmail())
                .jsonPath("$.fullName").isEqualTo("Current User");
    }

    @Test
    void shouldRejectGetCurrentUserWithoutToken() {
        restClient
                .get()
                .uri("/api/auth/me")
                .exchange()
                .expectStatus()
                .isUnauthorized();
    }
}

