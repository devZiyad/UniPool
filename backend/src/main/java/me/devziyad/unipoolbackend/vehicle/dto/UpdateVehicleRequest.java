package me.devziyad.unipoolbackend.vehicle.dto;

import jakarta.validation.constraints.Positive;
import lombok.Data;
import me.devziyad.unipoolbackend.common.VehicleType;

@Data
public class UpdateVehicleRequest {
    private String make;
    private String model;
    private String color;
    private String plateNumber;

    @Positive(message = "Seat count must be positive")
    private Integer seatCount;

    private VehicleType type;
}