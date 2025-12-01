package me.devziyad.springbootbackend.vehicle;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vehicles")
@RequiredArgsConstructor
@CrossOrigin
public class VehicleController {

    private final VehicleService vehicleService;

    @PostMapping
    public ResponseEntity<Vehicle> create(@RequestBody CreateVehicleRequest request) {
        Vehicle v = Vehicle.builder()
                .make(request.getMake())
                .model(request.getModel())
                .color(request.getColor())
                .plateNumber(request.getPlateNumber())
                .seatCount(request.getSeatCount())
                .build();

        Vehicle saved = vehicleService.createVehicle(v, request.getOwnerId());
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/owner/{ownerId}")
    public ResponseEntity<List<Vehicle>> forOwner(@PathVariable Long ownerId) {
        return ResponseEntity.ok(vehicleService.getVehiclesForUser(ownerId));
    }

    @DeleteMapping("/{vehicleId}")
    public ResponseEntity<Void> delete(@PathVariable Long vehicleId) {
        vehicleService.deleteVehicle(vehicleId);
        return ResponseEntity.ok().build();
    }

    @Data
    public static class CreateVehicleRequest {
        private Long ownerId;
        private String make;
        private String model;
        private String color;
        private String plateNumber;
        private int seatCount;
    }
}