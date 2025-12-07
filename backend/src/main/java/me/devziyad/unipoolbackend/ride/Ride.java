package me.devziyad.unipoolbackend.ride;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.vehicle.Vehicle;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "rides", indexes = {
    @Index(name = "idx_ride_driver_id", columnList = "driver_id"),
    @Index(name = "idx_ride_status", columnList = "status"),
    @Index(name = "idx_ride_departure_time_start", columnList = "departureTimeStart"),
    @Index(name = "idx_ride_departure_time_end", columnList = "departureTimeEnd")
})
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
    private Instant departureTimeStart;

    @Column(nullable = false)
    private Instant departureTimeEnd;

    @Column(nullable = false)
    @jakarta.validation.constraints.Min(value = 1, message = "Total seats must be at least 1")
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
    private Instant createdAt = Instant.now();

    @Column(columnDefinition = "TEXT")
    private String routePolyline;

    @OneToMany(mappedBy = "ride", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @Builder.Default
    private java.util.List<me.devziyad.unipoolbackend.booking.Booking> bookings = new java.util.ArrayList<>();
}