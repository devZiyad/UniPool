package me.devziyad.unipoolbackend.notification;

import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.notification.dto.NotificationResponse;
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

    @lombok.Data
    public static class UnreadCountResponse {
        private final Long count;

        public UnreadCountResponse(Long count) {
            this.count = count;
        }
    }
}