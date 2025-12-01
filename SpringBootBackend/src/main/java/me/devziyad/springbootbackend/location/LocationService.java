package me.devziyad.springbootbackend.location;

import me.devziyad.springbootbackend.location.dto.*;
import me.devziyad.springbootbackend.util.RoutingService.RouteInfo;

import java.util.List;
import java.util.Map;

public interface LocationService {
    LocationResponse createLocation(CreateLocationRequest request, Long userId);
    LocationResponse getLocationById(Long id);
    List<LocationResponse> getUserLocations(Long userId);
    List<LocationResponse> getUserFavoriteLocations(Long userId);
    LocationResponse updateLocation(Long id, CreateLocationRequest request, Long userId);
    void deleteLocation(Long id, Long userId);
    DistanceResponse calculateDistance(Long locationAId, Long locationBId);
    RouteInfo getRouteInfo(Long locationAId, Long locationBId);
    List<Map<String, Object>> searchLocation(String query);
    String reverseGeocode(Double latitude, Double longitude);
}