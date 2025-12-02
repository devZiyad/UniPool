package me.devziyad.unipoolbackend.booking.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class CreateBookingRequest {
    @NotNull(message = "Ride ID is required")
    private Long rideId;
    
    @NotNull(message = "Number of seats is required")
    @Positive(message = "Seats must be positive")
    private Integer seats;
}

