package me.devziyad.unipoolbackend.vehicle.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class CreateVehicleRequest {
    @NotBlank(message = "Make is required")
    private String make;

    @NotBlank(message = "Model is required")
    private String model;

    private String color;

    @NotBlank(message = "Plate number is required")
    private String plateNumber;

    @NotNull(message = "Seat count is required")
    @Positive(message = "Seat count must be positive")
    private Integer seatCount;
}