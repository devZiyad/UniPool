package me.devziyad.unipoolbackend.booking;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.user.User;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "bookings")
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
    @JoinColumn(name = "ride_id")
    private Ride ride;

    @ManyToOne(optional = false)
    @JoinColumn(name = "rider_id")
    private User rider;

    @Column(nullable = false)
    private Integer seatsBooked;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private BookingStatus status = BookingStatus.PENDING;

    @Column(nullable = false)
    private BigDecimal costForThisRider;

    @Column(nullable = false, updatable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column
    private LocalDateTime cancelledAt;
}