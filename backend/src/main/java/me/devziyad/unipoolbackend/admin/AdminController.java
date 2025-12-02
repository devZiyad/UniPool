package me.devziyad.unipoolbackend.admin;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.booking.Booking;
import me.devziyad.unipoolbackend.booking.BookingRepository;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.payment.Payment;
import me.devziyad.unipoolbackend.payment.PaymentRepository;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.user.UserService;
import me.devziyad.unipoolbackend.user.dto.UserResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AdminController {

    private final AuthService authService;
    private final UserService userService;
    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;
    private final PaymentRepository paymentRepository;

    private void checkAdmin() {
        if (authService.getCurrentUser().getRole() != Role.ADMIN) {
            throw new ForbiddenException("Admin access required");
        }
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        checkAdmin();
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<UserResponse> getUser(@PathVariable Long id) {
        checkAdmin();
        return ResponseEntity.ok(userService.getUserById(id));
    }

    @PutMapping("/users/{id}/enable")
    public ResponseEntity<UserResponse> enableUser(@PathVariable Long id, @RequestBody EnableUserRequest request) {
        checkAdmin();
        return ResponseEntity.ok(userService.enableUser(id, request.getEnabled()));
    }

    @GetMapping("/rides")
    public ResponseEntity<List<Ride>> getAllRides() {
        checkAdmin();
        return ResponseEntity.ok(rideRepository.findAll());
    }

    @GetMapping("/rides/{id}")
    public ResponseEntity<Ride> getRide(@PathVariable Long id) {
        checkAdmin();
        return ResponseEntity.ok(rideRepository.findById(id)
                .orElseThrow(() -> new me.devziyad.unipoolbackend.exception.ResourceNotFoundException("Ride not found")));
    }

    @PutMapping("/rides/{id}/complete")
    public ResponseEntity<Void> forceCompleteRide(@PathVariable Long id) {
        checkAdmin();
        Ride ride = rideRepository.findById(id)
                .orElseThrow(() -> new me.devziyad.unipoolbackend.exception.ResourceNotFoundException("Ride not found"));
        ride.setStatus(RideStatus.COMPLETED);
        rideRepository.save(ride);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/bookings")
    public ResponseEntity<List<Booking>> getAllBookings() {
        checkAdmin();
        return ResponseEntity.ok(bookingRepository.findAll());
    }

    @GetMapping("/bookings/{id}")
    public ResponseEntity<Booking> getBooking(@PathVariable Long id) {
        checkAdmin();
        return ResponseEntity.ok(bookingRepository.findById(id)
                .orElseThrow(() -> new me.devziyad.unipoolbackend.exception.ResourceNotFoundException("Booking not found")));
    }

    @GetMapping("/payments")
    public ResponseEntity<List<Payment>> getAllPayments() {
        checkAdmin();
        return ResponseEntity.ok(paymentRepository.findAll());
    }

    @GetMapping("/payments/{id}")
    public ResponseEntity<Payment> getPayment(@PathVariable Long id) {
        checkAdmin();
        return ResponseEntity.ok(paymentRepository.findById(id)
                .orElseThrow(() -> new me.devziyad.unipoolbackend.exception.ResourceNotFoundException("Payment not found")));
    }

    @lombok.Data
    public static class EnableUserRequest {
        private Boolean enabled;
    }
}

