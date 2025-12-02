package me.devziyad.unipoolbackend.notification;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.common.NotificationType;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.notification.dto.NotificationResponse;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    private NotificationResponse toResponse(Notification notification) {
        return NotificationResponse.builder()
                .id(notification.getId())
                .userId(notification.getUser().getId())
                .type(notification.getType())
                .title(notification.getTitle())
                .body(notification.getBody())
                .read(notification.getRead())
                .createdAt(notification.getCreatedAt())
                .build();
    }

    @Override
    @Transactional
    public NotificationResponse createNotification(Long userId, String title, String body, NotificationType type) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Notification notification = Notification.builder()
                .user(user)
                .type(type)
                .title(title)
                .body(body)
                .read(false)
                .build();

        return toResponse(notificationRepository.save(notification));
    }

    @Override
    public List<NotificationResponse> getNotificationsForUser(Long userId) {
        return notificationRepository.findByUserId(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<NotificationResponse> getUnreadNotificationsForUser(Long userId) {
        return notificationRepository.findByUserIdAndReadFalse(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public Long getUnreadCount(Long userId) {
        return (long) notificationRepository.findByUserIdAndReadFalse(userId).size();
    }

    @Override
    @Transactional
    public void markAsRead(Long notificationId, Long userId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification not found"));

        if (!notification.getUser().getId().equals(userId)) {
            throw new ForbiddenException("You can only mark your own notifications as read");
        }

        notification.setRead(true);
        notificationRepository.save(notification);
    }

    @Override
    @Transactional
    public void markAllAsRead(Long userId) {
        List<Notification> list = notificationRepository.findByUserIdAndReadFalse(userId);
        list.forEach(n -> n.setRead(true));
        notificationRepository.saveAll(list);
    }
}