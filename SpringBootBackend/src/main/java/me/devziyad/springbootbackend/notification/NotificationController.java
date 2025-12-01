package me.devziyad.springbootbackend.notification;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
@CrossOrigin
public class NotificationController {

    private final NotificationService notificationService;

    @PostMapping
    public ResponseEntity<Notification> create(@RequestBody CreateNotificationRequest request) {
        Notification n = notificationService.createNotification(
                request.getUserId(),
                request.getTitle(),
                request.getBody()
        );
        return ResponseEntity.ok(n);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Notification>> forUser(@PathVariable Long userId) {
        return ResponseEntity.ok(notificationService.getNotificationsForUser(userId));
    }

    @PostMapping("/{id}/read")
    public ResponseEntity<Void> markRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/user/{userId}/read-all")
    public ResponseEntity<Void> markAllRead(@PathVariable Long userId) {
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok().build();
    }

    @Data
    public static class CreateNotificationRequest {
        private Long userId;
        private String title;
        private String body;
    }
}