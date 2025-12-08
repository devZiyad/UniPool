package me.devziyad.unipoolbackend.ride.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import me.devziyad.unipoolbackend.booking.dto.BookingResponse;
import me.devziyad.unipoolbackend.common.RideStatus;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RideResponse {
    private Long rideId;
    private Long driverId;
    private String driverName;
    private BigDecimal driverRating;
    private Long vehicleId;
    private String vehicleMake;
    private String vehicleModel;
    private String vehiclePlateNumber;
    private Integer vehicleSeatCount;
    private Long pickupLocationId;
    private String pickupLocationLabel;
    private Double pickupLatitude;
    private Double pickupLongitude;
    private Long destinationLocationId;
    private String destinationLocationLabel;
    private Double destinationLatitude;
    private Double destinationLongitude;
    private Instant departureTimeStart;
    private Instant departureTimeEnd;
    private Integer totalSeats;
    private Integer availableSeats;
    private Double estimatedDistanceKm;
    private Double routeDistanceKm;
    private Integer estimatedDurationMinutes;
    private BigDecimal basePrice;
    private BigDecimal pricePerSeat;
    private RideStatus status;
    private Instant createdAt;
    private Long routeId;
    private List<BookingResponse> bookings;
}

