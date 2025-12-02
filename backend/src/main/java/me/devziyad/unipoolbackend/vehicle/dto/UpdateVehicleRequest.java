package me.devziyad.unipoolbackend.vehicle.dto;

import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class UpdateVehicleRequest {
    private String make;
    private String model;
    private String color;
    private String plateNumber;

    @Positive(message = "Seat count must be positive")
    private Integer seatCount;

    private Boolean active;
}