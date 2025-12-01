package me.devziyad.springbootbackend.payment;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import me.devziyad.springbootbackend.common.PaymentMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
@CrossOrigin
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/initiate")
    public ResponseEntity<Payment> initiate(@RequestBody PaymentRequest request) {
        Payment payment = paymentService.initiatePayment(
                request.getBookingId(),
                request.getPayerId(),
                request.getMethod()
        );
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Payment> get(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.getPayment(id));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Payment>> forUser(@PathVariable Long userId) {
        return ResponseEntity.ok(paymentService.getPaymentsForUser(userId));
    }

    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<List<Payment>> forBooking(@PathVariable Long bookingId) {
        return ResponseEntity.ok(paymentService.getPaymentsForBooking(bookingId));
    }

    @Data
    public static class PaymentRequest {
        private Long bookingId;
        private Long payerId;
        private PaymentMethod method;
    }
}