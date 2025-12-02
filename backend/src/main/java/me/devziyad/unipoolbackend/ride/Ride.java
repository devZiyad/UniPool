package me.devziyad.unipoolbackend.ride;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.vehicle.Vehicle;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "rides")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Ride {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "driver_id")
    private User driver;

    @ManyToOne(optional = false)
    @JoinColumn(name = "vehicle_id")
    private Vehicle vehicle;

    @ManyToOne(optional = false)
    @JoinColumn(name = "pickup_location_id")
    private Location pickupLocation;

    @ManyToOne(optional = false)
    @JoinColumn(name = "destination_location_id")
    private Location destinationLocation;

    @Column(nullable = false)
    private LocalDateTime departureTime;

    @Column(nullable = false)
    private Integer totalSeats;

    @Column(nullable = false)
    private Integer availableSeats;

    @Column(nullable = false)
    private Double estimatedDistanceKm;

    @Column(nullable = false)
    private Double routeDistanceKm;

    @Column(nullable = false)
    private Integer estimatedDurationMinutes;

    @Column(nullable = false)
    private BigDecimal basePrice;

    @Column(nullable = false)
    private BigDecimal pricePerSeat;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private RideStatus status = RideStatus.POSTED;

    @Column(nullable = false, updatable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column
    private String routePolyline;
}