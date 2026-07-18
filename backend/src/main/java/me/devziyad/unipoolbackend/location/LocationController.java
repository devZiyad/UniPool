package me.devziyad.unipoolbackend.location;

import jakarta.validation.Valid;
import lombok.Data;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.location.dto.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/locations")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class LocationController {

    private final LocationService locationService;
    private final AuthService authService;

    @PostMapping
    public ResponseEntity<@NonNull LocationResponse> create(@Valid @RequestBody CreateLocationRequest request) {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(locationService.createLocation(request, userId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<@NonNull LocationResponse> getLocation(@PathVariable Long id) {
        return ResponseEntity.ok(locationService.getLocationById(id));
    }

    @GetMapping("/me")
    public ResponseEntity<@NonNull List<@NonNull LocationResponse>> getMyLocations() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(locationService.getUserLocations(userId));
    }

    @GetMapping("/me/favorites")
    public ResponseEntity<@NonNull List<@NonNull LocationResponse>> getMyFavoriteLocations() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(locationService.getUserFavoriteLocations(userId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<@NonNull LocationResponse> updateLocation(@PathVariable Long id,
                                                           @Valid @RequestBody CreateLocationRequest request) {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(locationService.updateLocation(id, request, userId));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<@NonNull Void> deleteLocation(@PathVariable Long id) {
        Long userId = authService.getCurrentUser().getId();
        locationService.deleteLocation(id, userId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/distance")
    public ResponseEntity<@NonNull DistanceResponse> calculateDistance(@Valid @RequestBody DistanceRequest request) {
        return ResponseEntity.ok(locationService.calculateDistance(
                request.getLocationAId(), request.getLocationBId()));
    }

    @PostMapping("/search")
    public ResponseEntity<@NonNull List<@NonNull Map<String, Object>>> searchLocation(@Valid @RequestBody SearchLocationRequest request) {
        return ResponseEntity.ok(locationService.searchLocation(request.getQuery()));
    }

    @GetMapping("/reverse-geocode")
    public ResponseEntity<@NonNull ReverseGeocodeResponse> reverseGeocode(
            @RequestParam Double latitude,
            @RequestParam Double longitude) {
        String address = locationService.reverseGeocode(latitude, longitude);
        return ResponseEntity.ok(new ReverseGeocodeResponse(address));
    }

    @Data
    public static class DistanceRequest {
        private Long locationAId;
        private Long locationBId;
    }

    @Data
    public static class ReverseGeocodeResponse {
        private final String address;

        public ReverseGeocodeResponse(String address) {
            this.address = address;
        }
    }
}