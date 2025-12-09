package me.devziyad.unipoolbackend.notification;

import lombok.NonNull;
import me.devziyad.unipoolbackend.common.NotificationType;
import me.devziyad.unipoolbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserNotificationPreferenceRepository extends JpaRepository<@NonNull UserNotificationPreference, @NonNull Long> {

    @NonNull
    List<@NonNull UserNotificationPreference> findByUser(User user);

    @NonNull
    List<@NonNull UserNotificationPreference> findByUserId(Long userId);

    @NonNull
    List<@NonNull UserNotificationPreference> findByUserIdAndEnabledTrue(Long userId);

    @NonNull
    List<@NonNull UserNotificationPreference> findByUserIdAndType(Long userId, NotificationType type);

    Optional<UserNotificationPreference> findByUserIdAndTypeAndEnabledTrue(Long userId, NotificationType type);

    @NonNull
    List<@NonNull UserNotificationPreference> findByEnabledTrueAndScheduledTimeIsNotNullAndScheduledTimeBefore(Instant time);
}

