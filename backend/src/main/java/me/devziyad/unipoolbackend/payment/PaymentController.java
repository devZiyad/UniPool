package me.devziyad.unipoolbackend.payment;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.payment.dto.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class PaymentController {

    private final PaymentService paymentService;
    private final AuthService authService;

    @PostMapping("/initiate")
    public ResponseEntity<PaymentResponse> initiatePayment(@Valid @RequestBody InitiatePaymentRequest request) {
        Long payerId = authService.getCurrentUser().getId();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(paymentService.initiatePayment(request, payerId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PaymentResponse> getPayment(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.getPaymentById(id));
    }

    @GetMapping("/me")
    public ResponseEntity<List<PaymentResponse>> getMyPayments() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(paymentService.getPaymentsForUser(userId));
    }

    @GetMapping("/me/driver")
    public ResponseEntity<List<PaymentResponse>> getMyDriverPayments() {
        Long driverId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(paymentService.getPaymentsForDriver(driverId));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<PaymentResponse>> getPaymentsForUser(@PathVariable Long userId) {
        return ResponseEntity.ok(paymentService.getPaymentsForUser(userId));
    }

    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<List<PaymentResponse>> getPaymentsForBooking(@PathVariable Long bookingId) {
        return ResponseEntity.ok(paymentService.getPaymentsForBooking(bookingId));
    }

    @PostMapping("/{id}/process")
    public ResponseEntity<PaymentResponse> processPayment(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.processPayment(id));
    }

    @PostMapping("/{id}/refund")
    public ResponseEntity<PaymentResponse> refundPayment(@PathVariable Long id) {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(paymentService.refundPayment(id, userId));
    }

    @GetMapping("/wallet/balance")
    public ResponseEntity<WalletBalanceResponse> getWalletBalance() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(new WalletBalanceResponse(paymentService.getWalletBalance(userId)));
    }

    @PostMapping("/wallet/topup")
    public ResponseEntity<PaymentResponse> topUpWallet(@Valid @RequestBody WalletTopUpRequest request) {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(paymentService.topUpWallet(request, userId));
    }

    @lombok.Data
    public static class WalletBalanceResponse {
        private final BigDecimal balance;

        public WalletBalanceResponse(BigDecimal balance) {
            this.balance = balance;
        }
    }
}