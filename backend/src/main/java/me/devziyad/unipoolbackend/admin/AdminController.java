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
import me.devziyad.unipoolbackend.rating.RatingRepository;
import me.devziyad.unipoolbackend.notification.NotificationRepository;
import me.devziyad.unipoolbackend.tracking.GpsTrackingRepository;
import me.devziyad.unipoolbackend.route.RouteRepository;
import me.devziyad.unipoolbackend.location.LocationRepository;
import me.devziyad.unipoolbackend.vehicle.VehicleRepository;
import jakarta.servlet.http.HttpServletRequest;
import me.devziyad.unipoolbackend.audit.ActionType;
import me.devziyad.unipoolbackend.audit.AuditService;
import me.devziyad.unipoolbackend.audit.AuditLogRepository;
import me.devziyad.unipoolbackend.user.UserRepository;
import me.devziyad.unipoolbackend.user.UserSettingsRepository;
import me.devziyad.unipoolbackend.moderation.UserReportRepository;
import me.devziyad.unipoolbackend.security.TokenBlacklistRepository;
import me.devziyad.unipoolbackend.security.FailedLoginAttemptRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
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
    private final RatingRepository ratingRepository;
    private final NotificationRepository notificationRepository;
    private final GpsTrackingRepository gpsTrackingRepository;
    private final RouteRepository routeRepository;
    private final LocationRepository locationRepository;
    private final VehicleRepository vehicleRepository;
    private final UserRepository userRepository;
    private final UserSettingsRepository userSettingsRepository;
    private final AuditService auditService;
    private final AuditLogRepository auditLogRepository;
    private final UserReportRepository userReportRepository;
    private final TokenBlacklistRepository tokenBlacklistRepository;
    private final FailedLoginAttemptRepository failedLoginAttemptRepository;

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
    public ResponseEntity<@NonNull UserResponse> enableUser(@PathVariable Long id, @RequestBody EnableUserRequest request, HttpServletRequest httpRequest) {
        checkAdmin();
        Long adminId = authService.getCurrentUser().getId();
        UserResponse response = userService.enableUser(id, request.getEnabled());
        
        // Audit log
        java.util.Map<String, Object> metadata = new java.util.HashMap<>();
        metadata.put("targetUserId", id);
        metadata.put("enabled", request.getEnabled());
        auditService.logAction(request.getEnabled() ? ActionType.USER_ENABLE : ActionType.USER_DISABLE, adminId, metadata, httpRequest);
        
        return ResponseEntity.ok(response);
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
    public ResponseEntity<Void> forceCompleteRide(@PathVariable Long id) {
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

    @PostMapping("/database/reset")
    @Transactional
    public ResponseEntity<Void> resetDatabase(HttpServletRequest httpRequest) {
        checkAdmin();
        
        // Delete in order to respect foreign key constraints
        // Order matters: delete entities with foreign keys to other entities first
        // 1. Entities that don't depend on users (or have nullable FKs)
        gpsTrackingRepository.deleteAll();
        
        // 2. Entities that depend on Booking, Ride, and User
        paymentRepository.deleteAll();
        ratingRepository.deleteAll();
        bookingRepository.deleteAll();
        
        // 3. Entities that depend on Ride and User
        userReportRepository.deleteAll();
        routeRepository.deleteAll();
        rideRepository.deleteAll();
        
        // 4. Entities that depend on User only
        vehicleRepository.deleteAll();
        locationRepository.deleteAll();
        notificationRepository.deleteAll();
        auditLogRepository.deleteAll();
        failedLoginAttemptRepository.deleteAll();
        tokenBlacklistRepository.deleteAll();
        userSettingsRepository.deleteAll();
        
        // 5. Finally, delete users
        userRepository.deleteAll();
        
        // Audit log (this will fail if user is deleted, so we log before deletion)
        // Actually, we can't log after deletion since adminId won't exist
        // We'll skip the audit log for database reset to avoid circular dependency
        // auditService.logAction(ActionType.DATABASE_RESET, adminId, httpRequest);
        
        return ResponseEntity.ok().build();
    }

    @lombok.Data
    public static class EnableUserRequest {
        private Boolean enabled;
    }
}

