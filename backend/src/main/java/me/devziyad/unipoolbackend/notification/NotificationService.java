package me.devziyad.unipoolbackend.notification;

import me.devziyad.unipoolbackend.common.NotificationType;
import me.devziyad.unipoolbackend.notification.dto.NotificationResponse;

import java.util.List;

public interface NotificationService {
    NotificationResponse createNotification(Long userId, String title, String body, NotificationType type);
    List<NotificationResponse> getNotificationsForUser(Long userId);
    List<NotificationResponse> getUnreadNotificationsForUser(Long userId);
    Long getUnreadCount(Long userId);
    void markAsRead(Long notificationId, Long userId);
    void markAllAsRead(Long userId);
}