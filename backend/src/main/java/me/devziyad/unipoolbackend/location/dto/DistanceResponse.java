package me.devziyad.unipoolbackend.location.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DistanceResponse {
    private Double distanceKm;
    private Integer estimatedDurationMinutes;
}