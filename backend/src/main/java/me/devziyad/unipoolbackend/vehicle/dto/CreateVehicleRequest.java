package me.devziyad.unipoolbackend.vehicle.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CreateVehicleRequest {
    @NotBlank(message = "Make is required")
    @Size(max = 100, message = "Make must not exceed 100 characters")
    private String make;

    @NotBlank(message = "Model is required")
    @Size(max = 100, message = "Model must not exceed 100 characters")
    private String model;

    @Size(max = 100, message = "Color must not exceed 100 characters")
    private String color;

    @NotBlank(message = "Plate number is required")
    @Size(max = 50, message = "Plate number must not exceed 50 characters")
    private String plateNumber;

    @NotNull(message = "Seat count is required")
    @Positive(message = "Seat count must be positive")
    private Integer seatCount;
}