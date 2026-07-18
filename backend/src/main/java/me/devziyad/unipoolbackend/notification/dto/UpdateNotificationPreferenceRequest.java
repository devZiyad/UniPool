package me.devziyad.unipoolbackend.notification.dto;

import lombok.Data;
import me.devziyad.unipoolbackend.common.NotificationType;

import java.time.Instant;

@Data
public class UpdateNotificationPreferenceRequest {
    private NotificationType type;
    private String customText;
    private Instant scheduledTime;
    private Boolean enabled;
}

