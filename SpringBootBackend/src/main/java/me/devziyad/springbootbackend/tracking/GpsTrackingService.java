package me.devziyad.springbootbackend.tracking;

import me.devziyad.springbootbackend.tracking.dto.GpsLocationResponse;

public interface GpsTrackingService {
    void updateLocation(Long rideId, Double latitude, Double longitude);
    GpsLocationResponse getCurrentLocation(Long rideId);
    void startTracking(Long rideId);
    void stopTracking(Long rideId);
}

