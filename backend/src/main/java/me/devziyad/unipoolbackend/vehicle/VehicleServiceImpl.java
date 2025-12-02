package me.devziyad.unipoolbackend.vehicle;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import me.devziyad.unipoolbackend.vehicle.dto.CreateVehicleRequest;
import me.devziyad.unipoolbackend.vehicle.dto.UpdateVehicleRequest;
import me.devziyad.unipoolbackend.vehicle.dto.VehicleResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class VehicleServiceImpl implements VehicleService {

    private final VehicleRepository vehicleRepository;
    private final UserRepository userRepository;

    private VehicleResponse toResponse(Vehicle vehicle) {
        return VehicleResponse.builder()
                .id(vehicle.getId())
                .make(vehicle.getMake())
                .model(vehicle.getModel())
                .color(vehicle.getColor())
                .plateNumber(vehicle.getPlateNumber())
                .seatCount(vehicle.getSeatCount())
                .ownerId(vehicle.getOwner().getId())
                .ownerName(vehicle.getOwner().getFullName())
                .active(vehicle.getActive())
                .createdAt(vehicle.getCreatedAt())
                .build();
    }

    @Override
    @Transactional
    public VehicleResponse createVehicle(CreateVehicleRequest request, Long ownerId) {
        User owner = userRepository.findById(ownerId)
                .orElseThrow(() -> new ResourceNotFoundException("Owner not found"));

        if (vehicleRepository.findByPlateNumber(request.getPlateNumber()).isPresent()) {
            throw new IllegalArgumentException("Vehicle with this plate number already exists");
        }

        Vehicle vehicle = Vehicle.builder()
                .make(request.getMake())
                .model(request.getModel())
                .color(request.getColor())
                .plateNumber(request.getPlateNumber())
                .seatCount(request.getSeatCount())
                .owner(owner)
                .active(true)
                .build();

        return toResponse(vehicleRepository.save(vehicle));
    }

    @Override
    public VehicleResponse getVehicleById(Long id) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found"));
        return toResponse(vehicle);
    }

    @Override
    public List<VehicleResponse> getVehiclesForUser(Long ownerId) {
        return vehicleRepository.findByOwnerId(ownerId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<VehicleResponse> getActiveVehiclesForUser(Long ownerId) {
        return vehicleRepository.findByOwnerId(ownerId).stream()
                .filter(Vehicle::getActive)
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public VehicleResponse updateVehicle(Long id, UpdateVehicleRequest request, Long ownerId) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found"));

        if (!vehicle.getOwner().getId().equals(ownerId)) {
            throw new ForbiddenException("You can only update your own vehicles");
        }

        if (request.getMake() != null) vehicle.setMake(request.getMake());
        if (request.getModel() != null) vehicle.setModel(request.getModel());
        if (request.getColor() != null) vehicle.setColor(request.getColor());
        if (request.getPlateNumber() != null) vehicle.setPlateNumber(request.getPlateNumber());
        if (request.getSeatCount() != null) vehicle.setSeatCount(request.getSeatCount());
        if (request.getActive() != null) vehicle.setActive(request.getActive());

        return toResponse(vehicleRepository.save(vehicle));
    }

    @Override
    @Transactional
    public void deleteVehicle(Long id, Long ownerId) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found"));

        if (!vehicle.getOwner().getId().equals(ownerId)) {
            throw new ForbiddenException("You can only delete your own vehicles");
        }

        vehicleRepository.delete(vehicle);
    }

    @Override
    @Transactional
    public VehicleResponse setActiveVehicle(Long id, Long ownerId) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found"));

        if (!vehicle.getOwner().getId().equals(ownerId)) {
            throw new ForbiddenException("You can only set your own vehicles as active");
        }

        vehicle.setActive(true);
        return toResponse(vehicleRepository.save(vehicle));
    }
}