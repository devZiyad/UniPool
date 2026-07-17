package me.devziyad.unipoolbackend.location.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LocationResponse {
    private Long id;
    private String label;
    private String address;
    private Double latitude;
    private Double longitude;
    private Long userId;
    private Boolean isFavorite;
}