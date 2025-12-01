package me.devziyad.springbootbackend.ride;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.springbootbackend.common.RideStatus;
import me.devziyad.springbootbackend.location.Location;
import me.devziyad.springbootbackend.user.User;
import me.devziyad.springbootbackend.vehicle.Vehicle;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "rides")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Ride {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    private User driver;

    @ManyToOne(optional = false)
    private Vehicle vehicle;

    @ManyToOne(optional = false)
    private Location pickupLocation;

    @ManyToOne(optional = false)
    private Location destinationLocation;

    private LocalDateTime departureTime;

    private int totalSeats;
    private int availableSeats;

    // For cost calculation / display
    private Double estimatedDistanceKm;
    private BigDecimal basePrice;     // price for whole ride
    private BigDecimal pricePerSeat;  // optional derived

    @Enumerated(EnumType.STRING)
    private RideStatus status;
}