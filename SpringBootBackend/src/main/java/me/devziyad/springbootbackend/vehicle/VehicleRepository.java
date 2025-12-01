package me.devziyad.springbootbackend.vehicle;

import me.devziyad.springbootbackend.vehicle.Vehicle;
import me.devziyad.springbootbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VehicleRepository extends JpaRepository<Vehicle, Long> {

    List<Vehicle> findByOwner(User owner);

    List<Vehicle> findByOwnerId(Long ownerId);
}