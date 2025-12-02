package me.devziyad.unipoolbackend.ride.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class CreateRideRequest {
    @NotNull(message = "Vehicle ID is required")
    private Long vehicleId;
    
    @NotNull(message = "Pickup location ID is required")
    private Long pickupLocationId;
    
    @NotNull(message = "Destination location ID is required")
    private Long destinationLocationId;
    
    @NotNull(message = "Departure time is required")
    @Future(message = "Departure time must be in the future")
    private LocalDateTime departureTime;
    
    @NotNull(message = "Total seats is required")
    @Positive(message = "Total seats must be positive")
    private Integer totalSeats;
    
    private BigDecimal basePrice;
    private BigDecimal pricePerSeat;
}

