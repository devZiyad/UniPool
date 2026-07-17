package me.devziyad.unipoolbackend.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PopularDestination {
    private Long locationId;
    private String locationLabel;
    private Long rideCount;
}

