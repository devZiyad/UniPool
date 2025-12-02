package me.devziyad.unipoolbackend.vehicle;

import me.devziyad.unipoolbackend.vehicle.dto.CreateVehicleRequest;
import me.devziyad.unipoolbackend.vehicle.dto.UpdateVehicleRequest;
import me.devziyad.unipoolbackend.vehicle.dto.VehicleResponse;

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