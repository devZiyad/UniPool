package me.devziyad.unipoolbackend.vehicle.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import me.devziyad.unipoolbackend.common.VehicleType;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VehicleResponse {
    private Long id;
    private String make;
    private String model;
    private String color;
    private String plateNumber;
    private Integer seatCount;
    private VehicleType type;
    private Long ownerId;
    private String ownerName;
    private Instant createdAt;
}