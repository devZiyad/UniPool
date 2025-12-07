package me.devziyad.unipoolbackend.user.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class VerifyUserRequest {
    @NotNull(message = "Verified status is required")
    private Boolean verified;
}

