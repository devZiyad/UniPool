package me.devziyad.unipoolbackend.payment;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.booking.Booking;
import me.devziyad.unipoolbackend.common.PaymentMethod;
import me.devziyad.unipoolbackend.common.PaymentStatus;
import me.devziyad.unipoolbackend.user.User;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "payments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(optional = false)
    @JoinColumn(name = "booking_id", unique = true)
    private Booking booking;

    @ManyToOne(optional = false)
    @JoinColumn(name = "payer_id")
    private User payer;

    @ManyToOne
    @JoinColumn(name = "driver_id")
    private User driver;

    @Column(nullable = false)
    private BigDecimal amount;

    @Column(nullable = false)
    private BigDecimal platformFee;

    @Column(nullable = false)
    private BigDecimal driverEarnings;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentMethod method;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private PaymentStatus status = PaymentStatus.INITIATED;

    @Column(unique = true)
    private String transactionRef;

    @Column(nullable = false, updatable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(nullable = false)
    @Builder.Default
    private LocalDateTime updatedAt = LocalDateTime.now();
}