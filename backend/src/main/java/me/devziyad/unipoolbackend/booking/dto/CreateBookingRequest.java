package me.devziyad.unipoolbackend.booking.dto;

import jakarta.validation.constraints.Future;
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

    @NotNull(message = "Pickup location ID is required")
    private Long pickupLocationId;

    @NotNull(message = "Dropoff location ID is required")
    private Long dropoffLocationId;

    @NotNull(message = "Pickup time start is required")
    @Future(message = "Pickup time start must be in the future")
    private java.time.Instant pickupTimeStart;

    @NotNull(message = "Pickup time end is required")
    @Future(message = "Pickup time end must be in the future")
    private java.time.Instant pickupTimeEnd;
}

