package me.devziyad.unipoolbackend.tracking.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GpsLocationResponse {
    private Long rideId;
    private Double latitude;
    private Double longitude;
    private Instant lastUpdate;
    private Boolean isActive;
}

