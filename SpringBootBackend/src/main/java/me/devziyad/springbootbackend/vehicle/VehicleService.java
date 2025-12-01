package me.devziyad.springbootbackend.vehicle;

import me.devziyad.springbootbackend.vehicle.dto.CreateVehicleRequest;
import me.devziyad.springbootbackend.vehicle.dto.UpdateVehicleRequest;
import me.devziyad.springbootbackend.vehicle.dto.VehicleResponse;

import java.util.List;

public interface VehicleService {
    VehicleResponse createVehicle(CreateVehicleRequest request, Long ownerId);
    VehicleResponse getVehicleById(Long id);
    List<VehicleResponse> getVehiclesForUser(Long ownerId);
    List<VehicleResponse> getActiveVehiclesForUser(Long ownerId);
    VehicleResponse updateVehicle(Long id, UpdateVehicleRequest request, Long ownerId);
    void deleteVehicle(Long id, Long ownerId);
    VehicleResponse setActiveVehicle(Long id, Long ownerId);
}