package me.devziyad.springbootbackend.notification;

import me.devziyad.springbootbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    List<Notification> findByUser(User user);

    List<Notification> findByUserId(Long userId);

    List<Notification> findByUserIdAndReadFalse(Long userId);
}