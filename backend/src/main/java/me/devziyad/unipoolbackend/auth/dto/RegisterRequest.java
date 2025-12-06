package me.devziyad.unipoolbackend.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank(message = "University ID is required")
    @Size(max = 300, message = "University ID must not exceed 300 characters")
    private String universityId;

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    @Size(max = 320, message = "Email must not exceed 320 characters")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters long")
    @Pattern(regexp = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[@$!%*?&#])[A-Za-z\\d@$!%*?&#]{8,}$", 
             message = "Password must contain at least one letter, one number, and one special character")
    private String password;

    @NotBlank(message = "Full name is required")
    @Size(max = 300, message = "Full name must not exceed 300 characters")
    private String fullName;

    @Size(max = 30, message = "Phone number must not exceed 30 characters")
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Phone number must be in E.164 format")
    private String phoneNumber;

    private String role; // RIDER, DRIVER, or BOTH
}