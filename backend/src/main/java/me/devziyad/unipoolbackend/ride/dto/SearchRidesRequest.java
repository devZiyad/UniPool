package me.devziyad.unipoolbackend.ride.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;

@Data
public class SearchRidesRequest {
    private Long pickupLocationId;
    private Double pickupLatitude;
    private Double pickupLongitude;
    private Double pickupRadiusKm;
    
    private Long destinationLocationId;
    private Double destinationLatitude;
    private Double destinationLongitude;
    private Double destinationRadiusKm;
    
    private Instant departureTimeFrom;
    private Instant departureTimeTo;
    
    private Integer minAvailableSeats;
    private BigDecimal maxPrice;
    
    private String sortBy; // distance, price, departureTime
}

