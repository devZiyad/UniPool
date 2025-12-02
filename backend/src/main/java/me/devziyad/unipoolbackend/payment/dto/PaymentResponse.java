package me.devziyad.unipoolbackend.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import me.devziyad.unipoolbackend.common.PaymentMethod;
import me.devziyad.unipoolbackend.common.PaymentStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentResponse {
    private Long id;
    private Long bookingId;
    private Long payerId;
    private String payerName;
    private Long driverId;
    private String driverName;
    private BigDecimal amount;
    private BigDecimal platformFee;
    private BigDecimal driverEarnings;
    private PaymentMethod method;
    private PaymentStatus status;
    private String transactionRef;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

