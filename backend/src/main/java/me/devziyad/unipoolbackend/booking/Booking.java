package me.devziyad.unipoolbackend.booking;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.user.User;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "bookings", indexes = {
    @Index(name = "idx_booking_ride_id", columnList = "ride_id"),
    @Index(name = "idx_booking_rider_id", columnList = "rider_id"),
    @Index(name = "idx_booking_status", columnList = "status")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "ride_id", nullable = false)
    private Ride ride;

    @ManyToOne(optional = false)
    @JoinColumn(name = "rider_id", nullable = false)
    private User rider;

    @ManyToOne(optional = false)
    @JoinColumn(name = "pickup_location_id", nullable = false)
    private Location pickupLocation;

    @ManyToOne(optional = false)
    @JoinColumn(name = "dropoff_location_id", nullable = false)
    private Location dropoffLocation;

    @Column(nullable = false)
    @jakarta.validation.constraints.Min(value = 1, message = "Seats booked must be at least 1")
    private Integer seatsBooked;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private BookingStatus status = BookingStatus.PENDING;

    @Column(nullable = false, precision = 19, scale = 2)
    private BigDecimal costForThisRider;

    @Column(nullable = false, updatable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(nullable = false)
    private Instant pickupTimeStart;

    @Column(nullable = false)
    private Instant pickupTimeEnd;

    @Column
    private Instant cancelledAt;
}