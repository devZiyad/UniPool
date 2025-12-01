package me.devziyad.springbootbackend.vehicle;

import java.util.List;

public interface VehicleService {

    Vehicle createVehicle(Vehicle vehicle, Long ownerId);

    List<Vehicle> getVehiclesForUser(Long ownerId);

    void deleteVehicle(Long vehicleId);
}