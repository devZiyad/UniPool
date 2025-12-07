package me.devziyad.unipoolbackend.ride.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;

@Data
public class CreateRideRequest {
    @NotNull(message = "Vehicle ID is required")
    private Long vehicleId;
    
    @NotNull(message = "Pickup location ID is required")
    private Long pickupLocationId;
    
    @NotNull(message = "Destination location ID is required")
    private Long destinationLocationId;
    
    @NotNull(message = "Departure time start is required")
    @Future(message = "Departure time start must be in the future")
    private Instant departureTimeStart;
    
    @NotNull(message = "Departure time end is required")
    @Future(message = "Departure time end must be in the future")
    private Instant departureTimeEnd;
    
    @NotNull(message = "Total seats is required")
    @Positive(message = "Total seats must be positive")
    private Integer totalSeats;
    
    @DecimalMin(value = "0.0", inclusive = false, message = "Base price must be positive")
    private BigDecimal basePrice;
    
    @DecimalMin(value = "0.0", inclusive = false, message = "Price per seat must be positive")
    private BigDecimal pricePerSeat;
}

