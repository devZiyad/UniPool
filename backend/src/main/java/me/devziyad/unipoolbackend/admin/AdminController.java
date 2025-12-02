package me.devziyad.unipoolbackend.admin;

import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.booking.BookingRepository;
import me.devziyad.unipoolbackend.booking.BookingService;
import me.devziyad.unipoolbackend.booking.dto.BookingResponse;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.payment.PaymentRepository;
import me.devziyad.unipoolbackend.payment.PaymentService;
import me.devziyad.unipoolbackend.payment.dto.PaymentResponse;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
import me.devziyad.unipoolbackend.ride.RideService;
import me.devziyad.unipoolbackend.ride.dto.RideResponse;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.user.UserService;
import me.devziyad.unipoolbackend.user.dto.UserResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AdminController {

    private final AuthService authService;
    private final UserService userService;
    private final RideService rideService;
    private final RideRepository rideRepository;
    private final BookingService bookingService;
    private final BookingRepository bookingRepository;
    private final PaymentService paymentService;
    private final PaymentRepository paymentRepository;

    private void checkAdmin() {
        if (authService.getCurrentUser().getRole() != Role.ADMIN) {
            throw new ForbiddenException("Admin access required");
        }
    }

    @GetMapping("/users")
    public ResponseEntity<@NonNull List<@NonNull UserResponse>> getAllUsers() {
        checkAdmin();
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<@NonNull UserResponse> getUser(@PathVariable Long id) {
        checkAdmin();
        return ResponseEntity.ok(userService.getUserById(id));
    }

    @PutMapping("/users/{id}/enable")
    public ResponseEntity<@NonNull UserResponse> enableUser(@PathVariable Long id, @RequestBody EnableUserRequest request) {
        checkAdmin();
        return ResponseEntity.ok(userService.enableUser(id, request.getEnabled()));
    }

    @GetMapping("/rides")
    public ResponseEntity<@NonNull List<@NonNull RideResponse>> getAllRides() {
        checkAdmin();
        List<RideResponse> rides = rideRepository.findAll().stream()
                .map(ride -> rideService.getRideById(ride.getId()))
                .collect(Collectors.toList());
        return ResponseEntity.ok(rides);
    }

    @GetMapping("/rides/{id}")
    public ResponseEntity<@NonNull RideResponse> getRide(@PathVariable Long id) {
        checkAdmin();
        return ResponseEntity.ok(rideService.getRideById(id));
    }

    @PutMapping("/rides/{id}/complete")
    public ResponseEntity<@NonNull Void> forceCompleteRide(@PathVariable Long id) {
        checkAdmin();
        Ride ride = rideRepository.findById(id)
                .orElseThrow(() -> new me.devziyad.unipoolbackend.exception.ResourceNotFoundException("Ride not found"));
        ride.setStatus(RideStatus.COMPLETED);
        rideRepository.save(ride);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/bookings")
    public ResponseEntity<@NonNull List<@NonNull BookingResponse>> getAllBookings() {
        checkAdmin();
        List<BookingResponse> bookings = bookingRepository.findAll().stream()
                .map(booking -> bookingService.getBookingById(booking.getId()))
                .collect(Collectors.toList());
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/bookings/{id}")
    public ResponseEntity<@NonNull BookingResponse> getBooking(@PathVariable Long id) {
        checkAdmin();
        return ResponseEntity.ok(bookingService.getBookingById(id));
    }

    @GetMapping("/payments")
    public ResponseEntity<@NonNull List<@NonNull PaymentResponse>> getAllPayments() {
        checkAdmin();
        List<PaymentResponse> payments = paymentRepository.findAll().stream()
                .map(payment -> paymentService.getPaymentById(payment.getId()))
                .collect(Collectors.toList());
        return ResponseEntity.ok(payments);
    }

    @GetMapping("/payments/{id}")
    public ResponseEntity<@NonNull PaymentResponse> getPayment(@PathVariable Long id) {
        checkAdmin();
        return ResponseEntity.ok(paymentService.getPaymentById(id));
    }

    @lombok.Data
    public static class EnableUserRequest {
        private Boolean enabled;
    }
}

