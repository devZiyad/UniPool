package me.devziyad.springbootbackend.payment.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import me.devziyad.springbootbackend.common.PaymentMethod;

@Data
public class InitiatePaymentRequest {
    @NotNull(message = "Booking ID is required")
    private Long bookingId;
    
    @NotNull(message = "Payment method is required")
    private PaymentMethod method;
}

