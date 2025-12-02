package me.devziyad.unipoolbackend.tracking;

import jakarta.validation.Valid;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
import me.devziyad.unipoolbackend.tracking.dto.GpsLocationResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/tracking")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class GpsTrackingController {

    private final GpsTrackingService trackingService;
    private final AuthService authService;
    private final RideRepository rideRepository;

    @PostMapping("/{rideId}/update")
    public ResponseEntity<Void> updateLocation(@PathVariable Long rideId,
                                                @Valid @RequestBody UpdateLocationRequest request) {
        Long userId = authService.getCurrentUser().getId();
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new me.devziyad.unipoolbackend.exception.ResourceNotFoundException("Ride not found"));

        if (!ride.getDriver().getId().equals(userId)) {
            throw new ForbiddenException("Only the driver can update location");
        }

        trackingService.updateLocation(rideId, request.getLatitude(), request.getLongitude());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{rideId}")
    public ResponseEntity<GpsLocationResponse> getCurrentLocation(@PathVariable Long rideId) {
        return ResponseEntity.ok(trackingService.getCurrentLocation(rideId));
    }

    @PostMapping("/{rideId}/start")
    public ResponseEntity<Void> startTracking(@PathVariable Long rideId) {
        Long userId = authService.getCurrentUser().getId();
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new me.devziyad.unipoolbackend.exception.ResourceNotFoundException("Ride not found"));

        if (!ride.getDriver().getId().equals(userId)) {
            throw new ForbiddenException("Only the driver can start tracking");
        }

        trackingService.startTracking(rideId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{rideId}/stop")
    public ResponseEntity<Void> stopTracking(@PathVariable Long rideId) {
        Long userId = authService.getCurrentUser().getId();
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new me.devziyad.unipoolbackend.exception.ResourceNotFoundException("Ride not found"));

        if (!ride.getDriver().getId().equals(userId)) {
            throw new ForbiddenException("Only the driver can stop tracking");
        }

        trackingService.stopTracking(rideId);
        return ResponseEntity.ok().build();
    }

    @Data
    public static class UpdateLocationRequest {
        private Double latitude;
        private Double longitude;
    }
}

