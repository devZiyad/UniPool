package me.devziyad.springbootbackend.vehicle;

import lombok.RequiredArgsConstructor;
import me.devziyad.springbootbackend.user.User;
import me.devziyad.springbootbackend.user.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class VehicleServiceImpl implements VehicleService {

    private final VehicleRepository vehicleRepository;
    private final UserRepository userRepository;

    @Override
    public Vehicle createVehicle(Vehicle vehicle, Long ownerId) {
        User owner = userRepository.findById(ownerId)
                .orElseThrow(() -> new IllegalArgumentException("Owner not found"));

        vehicle.setOwner(owner);
        return vehicleRepository.save(vehicle);
    }

    @Override
    public List<Vehicle> getVehiclesForUser(Long ownerId) {
        return vehicleRepository.findByOwnerId(ownerId);
    }

    @Override
    public void deleteVehicle(Long vehicleId) {
        vehicleRepository.deleteById(vehicleId);
    }
}