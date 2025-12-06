package me.devziyad.unipoolbackend.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateUserRequest {
    @NotBlank(message = "Full name is required")
    @Size(max = 300, message = "Full name must not exceed 300 characters")
    private String fullName;
    
    @Size(max = 30, message = "Phone number must not exceed 30 characters")
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Phone number must be in E.164 format")
    private String phoneNumber;
}