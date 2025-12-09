package me.devziyad.unipoolbackend.notification;

import jakarta.validation.Valid;
import lombok.Data;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.booking.Booking;
import me.devziyad.unipoolbackend.booking.BookingRepository;
import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.common.NotificationType;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.notification.dto.CreateNotificationPreferenceRequest;
import me.devziyad.unipoolbackend.notification.dto.NotificationPreferenceResponse;
import me.devziyad.unipoolbackend.notification.dto.NotificationResponse;
import me.devziyad.unipoolbackend.notification.dto.UpdateNotificationPreferenceRequest;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
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
    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;

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

    // Notification Sending Endpoints

    @PostMapping("/ride/{rideId}/notify-riders")
    public ResponseEntity<@NonNull NotifyRidersResponse> notifyRiders(
            @PathVariable Long rideId,
            @Valid @RequestBody NotifyRidersRequest request) {
        Long userId = authService.getCurrentUser().getId();
        
        // Get the ride
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));
        
        // Check if user is the driver of this ride
        if (!ride.getDriver().getId().equals(userId)) {
            throw new ForbiddenException("Only the driver can notify riders of their ride");
        }
        
        // Get all confirmed bookings for this ride
        List<Booking> bookings = bookingRepository.findByRideId(rideId).stream()
                .filter(b -> b.getStatus() == BookingStatus.CONFIRMED)
                .toList();
        
        // Send notifications to all riders
        int notifiedCount = 0;
        for (Booking booking : bookings) {
            notificationService.createNotification(
                    booking.getRider().getId(),
                    request.getTitle() != null ? request.getTitle() : "Ride Update",
                    request.getMessage() != null ? request.getMessage() : 
                            String.format("Update for ride to %s", ride.getDestinationLocation().getLabel()),
                    request.getType() != null ? request.getType() : NotificationType.RIDE_REMINDER
            );
            notifiedCount++;
        }
        
        return ResponseEntity.ok(new NotifyRidersResponse(notifiedCount));
    }

    @PostMapping("/send")
    public ResponseEntity<@NonNull NotificationResponse> sendNotification(
            @Valid @RequestBody SendNotificationRequest request) {
        Long userId = authService.getCurrentUser().getId();
        
        NotificationResponse response = notificationService.createNotification(
                request.getUserId() != null ? request.getUserId() : userId,
                request.getTitle(),
                request.getMessage(),
                request.getType() != null ? request.getType() : NotificationType.RIDE_REMINDER
        );
        
        return ResponseEntity.ok(response);
    }

    @lombok.Data
    public static class UnreadCountResponse {
        private final Long count;

        public UnreadCountResponse(Long count) {
            this.count = count;
        }
    }

    @Data
    public static class NotifyRidersRequest {
        private String title;
        private String message;
        private NotificationType type;
    }

    @Data
    public static class NotifyRidersResponse {
        private final int notifiedCount;

        public NotifyRidersResponse(int notifiedCount) {
            this.notifiedCount = notifiedCount;
        }
    }

    @Data
    public static class SendNotificationRequest {
        private Long userId;
        @jakarta.validation.constraints.NotBlank(message = "Title is required")
        private String title;
        @jakarta.validation.constraints.NotBlank(message = "Message is required")
        private String message;
        private NotificationType type;
    }
}