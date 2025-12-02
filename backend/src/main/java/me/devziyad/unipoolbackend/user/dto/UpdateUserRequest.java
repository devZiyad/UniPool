package me.devziyad.unipoolbackend.user.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UpdateUserRequest {
    @NotBlank(message = "Full name is required")
    private String fullName;
    private String phoneNumber;
}