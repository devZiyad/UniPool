package me.devziyad.springbootbackend.vehicle;

import me.devziyad.springbootbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface VehicleRepository extends JpaRepository<Vehicle, Long> {

    List<Vehicle> findByOwner(User owner);

    List<Vehicle> findByOwnerId(Long ownerId);
    
    Optional<Vehicle> findByPlateNumber(String plateNumber);
}