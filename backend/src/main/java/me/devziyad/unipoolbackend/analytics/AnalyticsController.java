package me.devziyad.unipoolbackend.analytics;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.analytics.dto.*;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/analytics")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AnalyticsController {

    private final AnalyticsService analyticsService;
    private final AuthService authService;

    @GetMapping("/driver/earnings")
    public ResponseEntity<DriverEarningsResponse> getDriverEarnings(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        Long driverId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(analyticsService.getDriverEarnings(driverId, from, to));
    }

    @GetMapping("/rider/spending")
    public ResponseEntity<RiderSpendingResponse> getRiderSpending(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        Long riderId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(analyticsService.getRiderSpending(riderId, from, to));
    }

    @GetMapping("/rides/stats")
    public ResponseEntity<RideStatsResponse> getRideStats() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(analyticsService.getRideStats(userId));
    }

    @GetMapping("/bookings/stats")
    public ResponseEntity<BookingStatsResponse> getBookingStats() {
        checkAdmin();
        return ResponseEntity.ok(analyticsService.getBookingStats());
    }

    @GetMapping("/destinations/popular")
    public ResponseEntity<PopularDestinationsResponse> getPopularDestinations(
            @RequestParam(required = false, defaultValue = "10") Integer limit) {
        checkAdmin();
        return ResponseEntity.ok(analyticsService.getPopularDestinations(limit));
    }

    @GetMapping("/times/peak")
    public ResponseEntity<PeakTimesResponse> getPeakTimes() {
        checkAdmin();
        return ResponseEntity.ok(analyticsService.getPeakTimes());
    }

    @GetMapping("/dashboard")
    public ResponseEntity<DashboardStatsResponse> getDashboardStats() {
        checkAdmin();
        return ResponseEntity.ok(analyticsService.getDashboardStats());
    }

    private void checkAdmin() {
        if (authService.getCurrentUser().getRole() != Role.ADMIN) {
            throw new ForbiddenException("Admin access required");
        }
    }
}

