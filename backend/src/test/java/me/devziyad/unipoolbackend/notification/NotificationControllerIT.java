package me.devziyad.unipoolbackend.notification;

import com.fasterxml.jackson.databind.ObjectMapper;
import me.devziyad.unipoolbackend.common.NotificationType;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.notification.dto.CreateNotificationPreferenceRequest;
import me.devziyad.unipoolbackend.notification.dto.NotificationPreferenceResponse;
import me.devziyad.unipoolbackend.notification.dto.UpdateNotificationPreferenceRequest;
import me.devziyad.unipoolbackend.util.TestUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.client.RestTestClient;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

import static org.junit.jupiter.api.Assertions.*;

@AutoConfigureRestTestClient
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@org.springframework.test.context.ActiveProfiles("test")
public class NotificationControllerIT {

    @Autowired
    private RestTestClient restClient;


    private String userToken;
    private String otherUserToken;
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        objectMapper = TestUtils.getObjectMapper();
        
        // Create a user for testing
        userToken = TestUtils.registerAndGetToken(
                restClient,
                "testuser@example.com",
                "testpass123!",
                "Test User",
                Role.RIDER
        );

        // Create another user for testing access control
        otherUserToken = TestUtils.registerAndGetToken(
                restClient,
                "otheruser@example.com",
                "otherpass123!",
                "Other User",
                Role.RIDER
        );
    }

    @Test
    void shouldCreateNotificationPreference() throws Exception {
        CreateNotificationPreferenceRequest request = new CreateNotificationPreferenceRequest();
        request.setType(NotificationType.RIDE_REMINDER);
        request.setCustomText("Don't forget your ride!");
        request.setScheduledTime(Instant.now().plus(1, ChronoUnit.HOURS));

        byte[] responseBytes = restClient
                .post()
                .uri("/api/notifications/preferences")
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .returnResult()
                .getResponseBody();

        NotificationPreferenceResponse response = objectMapper.readValue(
                new String(responseBytes),
                NotificationPreferenceResponse.class
        );

        assertNotNull(response.getId());
        assertEquals(NotificationType.RIDE_REMINDER, response.getType());
        assertEquals("Don't forget your ride!", response.getCustomText());
        assertNotNull(response.getScheduledTime());
        assertTrue(response.getEnabled());
        assertNotNull(response.getCreatedAt());
    }

    @Test
    void shouldCreateNotificationPreferenceWithoutScheduledTime() throws Exception {
        CreateNotificationPreferenceRequest request = new CreateNotificationPreferenceRequest();
        request.setType(NotificationType.BOOKING_CONFIRMED);
        request.setCustomText("Your booking is confirmed!");

        byte[] responseBytes = restClient
                .post()
                .uri("/api/notifications/preferences")
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .returnResult()
                .getResponseBody();

        NotificationPreferenceResponse response = objectMapper.readValue(
                new String(responseBytes),
                NotificationPreferenceResponse.class
        );

        assertNotNull(response.getId());
        assertEquals(NotificationType.BOOKING_CONFIRMED, response.getType());
        assertEquals("Your booking is confirmed!", response.getCustomText());
        assertNull(response.getScheduledTime());
    }

    @Test
    void shouldRejectCreateNotificationPreferenceWithoutAuth() {
        CreateNotificationPreferenceRequest request = new CreateNotificationPreferenceRequest();
        request.setType(NotificationType.RIDE_REMINDER);
        request.setCustomText("Test");

        restClient
                .post()
                .uri("/api/notifications/preferences")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isForbidden();
    }

    @Test
    void shouldRejectCreateNotificationPreferenceWithInvalidData() {
        CreateNotificationPreferenceRequest request = new CreateNotificationPreferenceRequest();
        // Missing required fields

        restClient
                .post()
                .uri("/api/notifications/preferences")
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isBadRequest();
    }

    @Test
    void shouldGetAllNotificationPreferences() throws Exception {
        // Create two preferences
        createPreference(NotificationType.RIDE_REMINDER, "Reminder 1");
        createPreference(NotificationType.BOOKING_CONFIRMED, "Booking confirmed");

        byte[] responseBytes = restClient
                .get()
                .uri("/api/notifications/preferences")
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .returnResult()
                .getResponseBody();

        java.util.List<NotificationPreferenceResponse> preferences = objectMapper.readValue(
                new String(responseBytes),
                objectMapper.getTypeFactory().constructCollectionType(
                        java.util.List.class,
                        NotificationPreferenceResponse.class
                )
        );

        assertNotNull(preferences);
        assertTrue(preferences.size() >= 2);
    }

    @Test
    void shouldGetNotificationPreferenceById() throws Exception {
        NotificationPreferenceResponse created = createPreference(NotificationType.RIDE_REMINDER, "Test preference");

        byte[] responseBytes = restClient
                .get()
                .uri("/api/notifications/preferences/" + created.getId())
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .returnResult()
                .getResponseBody();

        NotificationPreferenceResponse response = objectMapper.readValue(
                new String(responseBytes),
                NotificationPreferenceResponse.class
        );

        assertEquals(created.getId(), response.getId());
        assertEquals(NotificationType.RIDE_REMINDER, response.getType());
        assertEquals("Test preference", response.getCustomText());
    }

    @Test
    void shouldRejectGetNotificationPreferenceByOtherUser() throws Exception {
        NotificationPreferenceResponse created = createPreference(NotificationType.RIDE_REMINDER, "Test preference");

        restClient
                .get()
                .uri("/api/notifications/preferences/" + created.getId())
                .header("Authorization", "Bearer " + otherUserToken)
                .exchange()
                .expectStatus()
                .isForbidden();
    }

    @Test
    void shouldUpdateNotificationPreference() throws Exception {
        NotificationPreferenceResponse created = createPreference(NotificationType.RIDE_REMINDER, "Original text");

        UpdateNotificationPreferenceRequest updateRequest = new UpdateNotificationPreferenceRequest();
        updateRequest.setCustomText("Updated text");
        updateRequest.setEnabled(false);

        byte[] responseBytes = restClient
                .put()
                .uri("/api/notifications/preferences/" + created.getId())
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(updateRequest)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .returnResult()
                .getResponseBody();

        NotificationPreferenceResponse response = objectMapper.readValue(
                new String(responseBytes),
                NotificationPreferenceResponse.class
        );

        assertEquals(created.getId(), response.getId());
        assertEquals("Updated text", response.getCustomText());
        assertFalse(response.getEnabled());
        assertEquals(NotificationType.RIDE_REMINDER, response.getType()); // Should remain unchanged
    }

    @Test
    void shouldRejectUpdateNotificationPreferenceByOtherUser() throws Exception {
        NotificationPreferenceResponse created = createPreference(NotificationType.RIDE_REMINDER, "Test");

        UpdateNotificationPreferenceRequest updateRequest = new UpdateNotificationPreferenceRequest();
        updateRequest.setCustomText("Hacked text");

        restClient
                .put()
                .uri("/api/notifications/preferences/" + created.getId())
                .header("Authorization", "Bearer " + otherUserToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(updateRequest)
                .exchange()
                .expectStatus()
                .isForbidden();
    }

    @Test
    void shouldDeleteNotificationPreference() throws Exception {
        NotificationPreferenceResponse created = createPreference(NotificationType.RIDE_REMINDER, "To be deleted");

        restClient
                .delete()
                .uri("/api/notifications/preferences/" + created.getId())
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isOk();

        // Verify it's deleted
        restClient
                .get()
                .uri("/api/notifications/preferences/" + created.getId())
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isNotFound();
    }

    @Test
    void shouldRejectDeleteNotificationPreferenceByOtherUser() throws Exception {
        NotificationPreferenceResponse created = createPreference(NotificationType.RIDE_REMINDER, "Test");

        restClient
                .delete()
                .uri("/api/notifications/preferences/" + created.getId())
                .header("Authorization", "Bearer " + otherUserToken)
                .exchange()
                .expectStatus()
                .isForbidden();
    }

    @Test
    void shouldReturnNotFoundForNonExistentPreference() {
        restClient
                .get()
                .uri("/api/notifications/preferences/99999")
                .header("Authorization", "Bearer " + userToken)
                .exchange()
                .expectStatus()
                .isNotFound();
    }

    private NotificationPreferenceResponse createPreference(NotificationType type, String customText) throws Exception {
        CreateNotificationPreferenceRequest request = new CreateNotificationPreferenceRequest();
        request.setType(type);
        request.setCustomText(customText);

        byte[] responseBytes = restClient
                .post()
                .uri("/api/notifications/preferences")
                .header("Authorization", "Bearer " + userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .exchange()
                .expectStatus()
                .isOk()
                .expectBody()
                .returnResult()
                .getResponseBody();

        return objectMapper.readValue(
                new String(responseBytes),
                NotificationPreferenceResponse.class
        );
    }
}

