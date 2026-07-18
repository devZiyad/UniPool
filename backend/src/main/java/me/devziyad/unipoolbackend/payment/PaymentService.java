package me.devziyad.unipoolbackend.payment;

import me.devziyad.unipoolbackend.payment.dto.*;

import java.math.BigDecimal;
import java.util.List;

public interface PaymentService {
    PaymentResponse initiatePayment(InitiatePaymentRequest request, Long payerId);
    PaymentResponse getPaymentById(Long id);
    List<PaymentResponse> getPaymentsForUser(Long userId);
    List<PaymentResponse> getPaymentsForBooking(Long bookingId);
    List<PaymentResponse> getPaymentsForDriver(Long driverId);
    PaymentResponse processPayment(Long paymentId);
    PaymentResponse refundPayment(Long paymentId, Long userId);
    BigDecimal getWalletBalance(Long userId);
    PaymentResponse topUpWallet(WalletTopUpRequest request, Long userId);
}