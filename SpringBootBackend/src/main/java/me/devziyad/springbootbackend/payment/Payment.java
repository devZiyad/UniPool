package me.devziyad.springbootbackend.payment;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.springbootbackend.booking.Booking;
import me.devziyad.springbootbackend.common.PaymentMethod;
import me.devziyad.springbootbackend.common.PaymentStatus;
import me.devziyad.springbootbackend.user.User;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "payments")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // one booking -> possibly one payment (simple)
    @OneToOne(optional = false)
    private Booking booking;

    @ManyToOne(optional = false)
    private User payer;  // rider paying

    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    private PaymentMethod method;

    @Enumerated(EnumType.STRING)
    private PaymentStatus status;

    private String transactionRef;  // internal or fake gateway ref

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}