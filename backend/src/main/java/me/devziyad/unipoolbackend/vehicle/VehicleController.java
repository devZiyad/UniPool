package me.devziyad.unipoolbackend.vehicle;

import jakarta.validation.Valid;
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
    public ResponseEntity<VehicleResponse> create(@Valid @RequestBody CreateVehicleRequest request) {
        Long ownerId = authService.getCurrentUser().getId();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(vehicleService.createVehicle(request, ownerId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<VehicleResponse> getVehicle(@PathVariable Long id) {
        return ResponseEntity.ok(vehicleService.getVehicleById(id));
    }

    @GetMapping("/me")
    public ResponseEntity<List<VehicleResponse>> getMyVehicles() {
        Long ownerId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(vehicleService.getVehiclesForUser(ownerId));
    }

    @GetMapping("/me/active")
    public ResponseEntity<List<VehicleResponse>> getMyActiveVehicles() {
        Long ownerId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(vehicleService.getActiveVehiclesForUser(ownerId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<VehicleResponse> update(@PathVariable Long id,
                                                  @Valid @RequestBody UpdateVehicleRequest request) {
        Long ownerId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(vehicleService.updateVehicle(id, request, ownerId));
    }

    @PutMapping("/{id}/activate")
    public ResponseEntity<VehicleResponse> activate(@PathVariable Long id) {
        Long ownerId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(vehicleService.setActiveVehicle(id, ownerId));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        Long ownerId = authService.getCurrentUser().getId();
        vehicleService.deleteVehicle(id, ownerId);
        return ResponseEntity.ok().build();
    }
}