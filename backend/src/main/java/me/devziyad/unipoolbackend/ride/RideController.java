package me.devziyad.unipoolbackend.ride;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.ride.dto.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rides")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class RideController {

    private final RideService rideService;
    private final AuthService authService;

    @PostMapping
    public ResponseEntity<RideResponse> createRide(@Valid @RequestBody CreateRideRequest request) {
        Long driverId = authService.getCurrentUser().getId();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(rideService.createRide(request, driverId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<RideResponse> getRide(@PathVariable Long id) {
        return ResponseEntity.ok(rideService.getRideById(id));
    }

    @PostMapping("/search")
    public ResponseEntity<List<RideResponse>> searchRides(@Valid @RequestBody SearchRidesRequest request) {
        return ResponseEntity.ok(rideService.searchRides(request));
    }

    @GetMapping("/driver/{driverId}")
    public ResponseEntity<List<RideResponse>> getRidesByDriver(@PathVariable Long driverId) {
        return ResponseEntity.ok(rideService.getRidesByDriver(driverId));
    }

    @GetMapping("/me/driver")
    public ResponseEntity<List<RideResponse>> getMyRidesAsDriver() {
        Long driverId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(rideService.getMyRidesAsDriver(driverId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<RideResponse> updateRide(@PathVariable Long id,
                                                    @Valid @RequestBody UpdateRideRequest request) {
        Long driverId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(rideService.updateRide(id, request, driverId));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<RideResponse> updateRideStatus(@PathVariable Long id,
                                                        @RequestBody UpdateStatusRequest request) {
        Long driverId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(rideService.updateRideStatus(id, request.getStatus(), driverId));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> cancelRide(@PathVariable Long id) {
        Long driverId = authService.getCurrentUser().getId();
        rideService.cancelRide(id, driverId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}/available-seats")
    public ResponseEntity<Integer> getAvailableSeats(@PathVariable Long id) {
        return ResponseEntity.ok(rideService.getAvailableSeats(id));
    }

    @lombok.Data
    public static class UpdateStatusRequest {
        private RideStatus status;
    }
}

