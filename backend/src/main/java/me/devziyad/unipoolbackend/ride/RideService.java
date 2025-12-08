package me.devziyad.unipoolbackend.ride;

import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.ride.dto.*;

import java.util.List;

public interface RideService {
    RideResponse createRide(CreateRideRequest request, Long driverId);
    RideResponse getRideById(Long id);
    List<RideResponse> searchRides(SearchRidesRequest request);
    List<RideResponse> getRidesByDriver(Long driverId);
    List<RideResponse> getMyRidesAsDriver(Long driverId);
    RideResponse updateRide(Long id, UpdateRideRequest request, Long driverId);
    RideResponse updateRideStatus(Long id, RideStatus status, Long driverId);
    RideResponse updateRideRoute(Long id, Long routeId, Long driverId);
    void cancelRide(Long id, Long driverId);
    Integer getAvailableSeats(Long id);
}

