package me.devziyad.unipoolbackend.payment.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import me.devziyad.unipoolbackend.common.PaymentMethod;

@Data
public class InitiatePaymentRequest {
    @NotNull(message = "Booking ID is required")
    private Long bookingId;
    
    @NotNull(message = "Payment method is required")
    private PaymentMethod method;
}

