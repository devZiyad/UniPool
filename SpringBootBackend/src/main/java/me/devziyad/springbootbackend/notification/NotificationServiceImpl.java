package me.devziyad.springbootbackend.notification;

import lombok.RequiredArgsConstructor;
import me.devziyad.springbootbackend.user.User;
import me.devziyad.springbootbackend.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    @Override
    public Notification createNotification(Long userId, String title, String body) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Notification notification = Notification.builder()
                .user(user)
                .title(title)
                .body(body)
                .read(false)
                .createdAt(LocalDateTime.now())
                .build();

        return notificationRepository.save(notification);
    }

    @Override
    public List<Notification> getNotificationsForUser(Long userId) {
        return notificationRepository.findByUserId(userId);
    }

    @Override
    @Transactional
    public void markAsRead(Long notificationId) {
        Notification n = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new IllegalArgumentException("Notification not found"));
        n.setRead(true);
        notificationRepository.save(n);
    }

    @Override
    @Transactional
    public void markAllAsRead(Long userId) {
        List<Notification> list = notificationRepository.findByUserIdAndReadFalse(userId);
        list.forEach(n -> n.setRead(true));
        notificationRepository.saveAll(list);
    }
}