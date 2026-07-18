package me.devziyad.unipoolbackend.user.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UploadImageRequest {
    @NotBlank(message = "Image data is required (base64 encoded)")
    private String imageData; // Base64 encoded image
}

