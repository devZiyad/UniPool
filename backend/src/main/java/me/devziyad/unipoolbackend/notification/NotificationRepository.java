package me.devziyad.unipoolbackend.notification;

import lombok.NonNull;
import me.devziyad.unipoolbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<@NonNull Notification, @NonNull Long> {

    @NonNull
    List<@NonNull Notification> findByUser(User user);

    @NonNull
    List<@NonNull Notification> findByUserId(Long userId);

    @NonNull
    List<@NonNull Notification> findByUserIdAndReadFalse(Long userId);
}