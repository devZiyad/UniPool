package me.devziyad.unipoolbackend.vehicle.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

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
    private Long ownerId;
    private String ownerName;
    private Boolean active;
    private Instant createdAt;
}