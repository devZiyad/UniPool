package me.devziyad.springbootbackend.payment;

import lombok.RequiredArgsConstructor;
import me.devziyad.springbootbackend.booking.Booking;
import me.devziyad.springbootbackend.booking.BookingRepository;
import me.devziyad.springbootbackend.common.PaymentMethod;
import me.devziyad.springbootbackend.common.PaymentStatus;
import me.devziyad.springbootbackend.user.User;
import me.devziyad.springbootbackend.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PaymentServiceImpl implements PaymentService {

    private final PaymentRepository paymentRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public Payment initiatePayment(Long bookingId, Long payerId, PaymentMethod method) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));

        User payer = userRepository.findById(payerId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Payment payment = Payment.builder()
                .booking(booking)
                .payer(payer)
                .amount(booking.getCostForThisRider())
                .method(method)
                .status(PaymentStatus.INITIATED)
                .transactionRef("SIM-" + System.currentTimeMillis())
                .createdAt(LocalDateTime.now())
                .build();

        // Simulate instant settlement
        payment.setStatus(PaymentStatus.SETTLED);
        payment.setUpdatedAt(LocalDateTime.now());

        return paymentRepository.save(payment);
    }

    @Override
    public Payment getPayment(Long id) {
        return paymentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Payment not found"));
    }

    @Override
    public List<Payment> getPaymentsForUser(Long userId) {
        return paymentRepository.findByPayerId(userId);
    }

    @Override
    public List<Payment> getPaymentsForBooking(Long bookingId) {
        return paymentRepository.findByBookingId(bookingId);
    }
}