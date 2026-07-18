package me.devziyad.unipoolbackend.notification;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.common.NotificationType;
import me.devziyad.unipoolbackend.user.User;

import java.time.Instant;

@Entity
@Table(name = "user_notification_preferences", indexes = {
    @Index(name = "idx_user_notification_pref_user_id", columnList = "user_id"),
    @Index(name = "idx_user_notification_pref_type", columnList = "type"),
    @Index(name = "idx_user_notification_pref_enabled", columnList = "enabled")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserNotificationPreference {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationType type;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String customText;

    @Column(nullable = true)
    private Instant scheduledTime; // When to receive the notification (null = immediate or event-based)

    @Column(nullable = false)
    @Builder.Default
    private Boolean enabled = true;

    @Column(nullable = false, updatable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(nullable = false)
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @PreUpdate
    protected void onUpdate() {
        updatedAt = Instant.now();
    }
}

