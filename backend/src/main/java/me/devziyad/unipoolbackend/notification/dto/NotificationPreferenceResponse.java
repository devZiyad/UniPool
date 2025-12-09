package me.devziyad.unipoolbackend.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import me.devziyad.unipoolbackend.common.NotificationType;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationPreferenceResponse {
    private Long id;
    private Long userId;
    private NotificationType type;
    private String customText;
    private Instant scheduledTime;
    private Boolean enabled;
    private Instant createdAt;
    private Instant updatedAt;
}

