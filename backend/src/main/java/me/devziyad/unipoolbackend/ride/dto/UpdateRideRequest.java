package me.devziyad.unipoolbackend.ride.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.Positive;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class UpdateRideRequest {
    private Long pickupLocationId;
    private Long destinationLocationId;
    
    @Future(message = "Departure time must be in the future")
    private LocalDateTime departureTime;
    
    @Positive(message = "Total seats must be positive")
    private Integer totalSeats;
    
    private BigDecimal basePrice;
    private BigDecimal pricePerSeat;
}

