package me.devziyad.unipoolbackend.tracking.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GpsLocationResponse {
    private Long rideId;
    private Double latitude;
    private Double longitude;
    private LocalDateTime lastUpdate;
    private Boolean isActive;
}

