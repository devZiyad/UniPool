package me.devziyad.unipoolbackend.notification.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import me.devziyad.unipoolbackend.common.NotificationType;

import java.time.Instant;

@Data
public class CreateNotificationPreferenceRequest {
    @NotNull(message = "Type is required")
    private NotificationType type;

    @NotBlank(message = "Custom text is required")
    private String customText;

    private Instant scheduledTime; // Optional: when to receive the notification
}

