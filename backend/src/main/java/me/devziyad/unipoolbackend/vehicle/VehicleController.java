package me.devziyad.unipoolbackend.vehicle;

import jakarta.validation.Valid;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.vehicle.dto.CreateVehicleRequest;
import me.devziyad.unipoolbackend.vehicle.dto.UpdateVehicleRequest;
import me.devziyad.unipoolbackend.vehicle.dto.VehicleResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vehicles")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class VehicleController {

    private final VehicleService vehicleService;
    private final AuthService authService;

    @PostMapping
    public ResponseEntity<@NonNull VehicleResponse> create(@Valid @RequestBody CreateVehicleRequest request) {
        Long ownerId = authService.getCurrentUser().getId();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(vehicleService.createVehicle(request, ownerId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<@NonNull VehicleResponse> getVehicle(@PathVariable Long id) {
        return ResponseEntity.ok(vehicleService.getVehicleById(id));
    }

    @GetMapping("/me")
    public ResponseEntity<@NonNull List<@NonNull VehicleResponse>> getMyVehicles() {
        Long ownerId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(vehicleService.getVehiclesForUser(ownerId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<@NonNull VehicleResponse> update(@PathVariable Long id,
                                                  @Valid @RequestBody UpdateVehicleRequest request) {
        Long ownerId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(vehicleService.updateVehicle(id, request, ownerId));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<@NonNull Void> delete(@PathVariable Long id) {
        Long ownerId = authService.getCurrentUser().getId();
        vehicleService.deleteVehicle(id, ownerId);
        return ResponseEntity.ok().build();
    }
}