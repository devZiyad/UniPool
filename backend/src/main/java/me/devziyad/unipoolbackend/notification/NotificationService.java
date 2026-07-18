package me.devziyad.unipoolbackend.notification;

import me.devziyad.unipoolbackend.common.NotificationType;
import me.devziyad.unipoolbackend.notification.dto.CreateNotificationPreferenceRequest;
import me.devziyad.unipoolbackend.notification.dto.NotificationPreferenceResponse;
import me.devziyad.unipoolbackend.notification.dto.NotificationResponse;
import me.devziyad.unipoolbackend.notification.dto.UpdateNotificationPreferenceRequest;

import java.util.List;

public interface NotificationService {
    NotificationResponse createNotification(Long userId, String title, String body, NotificationType type);
    List<NotificationResponse> getNotificationsForUser(Long userId);
    List<NotificationResponse> getUnreadNotificationsForUser(Long userId);
    Long getUnreadCount(Long userId);
    void markAsRead(Long notificationId, Long userId);
    void markAllAsRead(Long userId);
    
    // Notification preference methods
    NotificationPreferenceResponse createNotificationPreference(Long userId, CreateNotificationPreferenceRequest request);
    List<NotificationPreferenceResponse> getNotificationPreferencesForUser(Long userId);
    NotificationPreferenceResponse getNotificationPreferenceById(Long preferenceId, Long userId);
    NotificationPreferenceResponse updateNotificationPreference(Long preferenceId, Long userId, UpdateNotificationPreferenceRequest request);
    void deleteNotificationPreference(Long preferenceId, Long userId);
}