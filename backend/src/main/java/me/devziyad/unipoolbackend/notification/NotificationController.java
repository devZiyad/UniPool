package me.devziyad.unipoolbackend.notification;

import jakarta.validation.Valid;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.notification.dto.CreateNotificationPreferenceRequest;
import me.devziyad.unipoolbackend.notification.dto.NotificationPreferenceResponse;
import me.devziyad.unipoolbackend.notification.dto.NotificationResponse;
import me.devziyad.unipoolbackend.notification.dto.UpdateNotificationPreferenceRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class NotificationController {

    private final NotificationService notificationService;
    private final AuthService authService;

    @GetMapping("/me")
    public ResponseEntity<@NonNull List<@NonNull NotificationResponse>> getMyNotifications() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(notificationService.getNotificationsForUser(userId));
    }

    @GetMapping("/me/unread")
    public ResponseEntity<@NonNull List<@NonNull NotificationResponse>> getMyUnreadNotifications() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(notificationService.getUnreadNotificationsForUser(userId));
    }

    @GetMapping("/me/unread-count")
    public ResponseEntity<@NonNull UnreadCountResponse> getUnreadCount() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(new UnreadCountResponse(notificationService.getUnreadCount(userId)));
    }

    @PostMapping("/{id}/read")
    public ResponseEntity<@NonNull Void> markAsRead(@PathVariable Long id) {
        Long userId = authService.getCurrentUser().getId();
        notificationService.markAsRead(id, userId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/me/read-all")
    public ResponseEntity<@NonNull Void> markAllAsRead() {
        Long userId = authService.getCurrentUser().getId();
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok().build();
    }

    // Notification Preference Endpoints

    @PostMapping("/preferences")
    public ResponseEntity<@NonNull NotificationPreferenceResponse> createNotificationPreference(
            @Valid @RequestBody CreateNotificationPreferenceRequest request) {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(notificationService.createNotificationPreference(userId, request));
    }

    @GetMapping("/preferences")
    public ResponseEntity<@NonNull List<@NonNull NotificationPreferenceResponse>> getMyNotificationPreferences() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(notificationService.getNotificationPreferencesForUser(userId));
    }

    @GetMapping("/preferences/{id}")
    public ResponseEntity<@NonNull NotificationPreferenceResponse> getNotificationPreference(@PathVariable Long id) {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(notificationService.getNotificationPreferenceById(id, userId));
    }

    @PutMapping("/preferences/{id}")
    public ResponseEntity<@NonNull NotificationPreferenceResponse> updateNotificationPreference(
            @PathVariable Long id,
            @Valid @RequestBody UpdateNotificationPreferenceRequest request) {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(notificationService.updateNotificationPreference(id, userId, request));
    }

    @DeleteMapping("/preferences/{id}")
    public ResponseEntity<@NonNull Void> deleteNotificationPreference(@PathVariable Long id) {
        Long userId = authService.getCurrentUser().getId();
        notificationService.deleteNotificationPreference(id, userId);
        return ResponseEntity.ok().build();
    }

    @lombok.Data
    public static class UnreadCountResponse {
        private final Long count;

        public UnreadCountResponse(Long count) {
            this.count = count;
        }
    }
}