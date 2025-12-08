package me.devziyad.unipoolbackend.route.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RouteResponse {
    private Long routeId;
    private Long createdByUserId;
    private String createdByName;
    private Double startLatitude;
    private Double startLongitude;
    private Double endLatitude;
    private Double endLongitude;
    private Double distanceKm;
    private Integer estimatedDurationMinutes;
    private String polyline;
    private Instant createdAt;
    private Instant updatedAt;
}

