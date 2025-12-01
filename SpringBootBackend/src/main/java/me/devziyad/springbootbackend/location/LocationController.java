package me.devziyad.springbootbackend.location;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/locations")
@RequiredArgsConstructor
@CrossOrigin
public class LocationController {

    private final LocationService locationService;

    @PostMapping
    public ResponseEntity<Location> create(@RequestBody Location location) {
        return ResponseEntity.ok(locationService.createLocation(location));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Location> get(@PathVariable Long id) {
        return ResponseEntity.ok(locationService.getLocation(id));
    }

    @GetMapping
    public ResponseEntity<List<Location>> getAll() {
        return ResponseEntity.ok(locationService.getAllLocations());
    }

    @PostMapping("/distance")
    public ResponseEntity<DistanceResponse> distance(@RequestBody DistanceRequest request) {
        Location a = locationService.getLocation(request.getLocationAId());
        Location b = locationService.getLocation(request.getLocationBId());
        double km = locationService.distanceKm(a, b);

        DistanceResponse resp = new DistanceResponse();
        resp.setDistanceKm(km);
        return ResponseEntity.ok(resp);
    }

    @Data
    public static class DistanceRequest {
        private Long locationAId;
        private Long locationBId;
    }

    @Data
    public static class DistanceResponse {
        private double distanceKm;
    }
}