package me.devziyad.springbootbackend.notification;

import java.util.List;

public interface NotificationService {

    Notification createNotification(Long userId, String title, String body);

    List<Notification> getNotificationsForUser(Long userId);

    void markAsRead(Long notificationId);

    void markAllAsRead(Long userId);
}