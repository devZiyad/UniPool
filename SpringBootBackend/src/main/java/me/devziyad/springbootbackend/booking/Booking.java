package me.devziyad.springbootbackend.booking;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.springbootbackend.common.BookingStatus;
import me.devziyad.springbootbackend.ride.Ride;
import me.devziyad.springbootbackend.user.User;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "bookings")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    private Ride ride;

    @ManyToOne(optional = false)
    private User rider;

    private int seatsBooked;

    @Enumerated(EnumType.STRING)
    private BookingStatus status;

    private BigDecimal costForThisRider;

    private LocalDateTime createdAt;
}