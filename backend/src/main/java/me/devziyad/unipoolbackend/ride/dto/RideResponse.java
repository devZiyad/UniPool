package me.devziyad.unipoolbackend.ride.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import me.devziyad.unipoolbackend.common.RideStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RideResponse {
    private Long id;
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
    private LocalDateTime departureTime;
    private Integer totalSeats;
    private Integer availableSeats;
    private Double estimatedDistanceKm;
    private Double routeDistanceKm;
    private Integer estimatedDurationMinutes;
    private BigDecimal basePrice;
    private BigDecimal pricePerSeat;
    private RideStatus status;
    private LocalDateTime createdAt;
    private String routePolyline;
}

