package me.devziyad.springbootbackend.payment;

import me.devziyad.springbootbackend.common.PaymentMethod;

import java.util.List;

public interface PaymentService {

    Payment initiatePayment(Long bookingId, Long payerId, PaymentMethod method);

    Payment getPayment(Long id);

    List<Payment> getPaymentsForUser(Long userId);

    List<Payment> getPaymentsForBooking(Long bookingId);
}