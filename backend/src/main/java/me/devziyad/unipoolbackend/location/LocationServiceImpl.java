package me.devziyad.unipoolbackend.location;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.location.dto.*;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import me.devziyad.unipoolbackend.util.DistanceUtil;
import me.devziyad.unipoolbackend.util.GeocodingService;
import me.devziyad.unipoolbackend.util.RoutingService;
import me.devziyad.unipoolbackend.util.RoutingService.RouteInfo;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LocationServiceImpl implements LocationService {

    private final LocationRepository locationRepository;
    private final UserRepository userRepository;
    private final RoutingService routingService;
    private final GeocodingService geocodingService;

    private LocationResponse toResponse(Location location) {
        return LocationResponse.builder()
                .id(location.getId())
                .label(location.getLabel())
                .address(location.getAddress())
                .latitude(location.getLatitude())
                .longitude(location.getLongitude())
                .userId(location.getUser() != null ? location.getUser().getId() : null)
                .isFavorite(location.getIsFavorite())
                .build();
    }

    @Override
    @Transactional
    public LocationResponse createLocation(CreateLocationRequest request, Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Validate coordinates
        if (request.getLatitude() < -90 || request.getLatitude() > 90) {
            throw new me.devziyad.unipoolbackend.exception.BusinessException("Latitude must be between -90 and 90");
        }
        if (request.getLongitude() < -180 || request.getLongitude() > 180) {
            throw new me.devziyad.unipoolbackend.exception.BusinessException("Longitude must be between -180 and 180");
        }

        Location location = Location.builder()
                .label(request.getLabel())
                .address(request.getAddress())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .user(user)
                .isFavorite(request.getIsFavorite() != null ? request.getIsFavorite() : false)
                .build();

        return toResponse(locationRepository.save(location));
    }

    @Override
    public LocationResponse getLocationById(Long id) {
        Location location = locationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Location not found"));
        return toResponse(location);
    }

    @Override
    public List<LocationResponse> getUserLocations(Long userId) {
        return locationRepository.findByUserId(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<LocationResponse> getUserFavoriteLocations(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return locationRepository.findByUserAndIsFavoriteTrue(user).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public LocationResponse updateLocation(Long id, CreateLocationRequest request, Long userId) {
        Location location = locationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Location not found"));

        if (location.getUser() != null && !location.getUser().getId().equals(userId)) {
            throw new ForbiddenException("You can only update your own locations");
        }

        if (request.getLabel() != null) location.setLabel(request.getLabel());
        if (request.getAddress() != null) location.setAddress(request.getAddress());
        if (request.getLatitude() != null) {
            if (request.getLatitude() < -90 || request.getLatitude() > 90) {
                throw new me.devziyad.unipoolbackend.exception.BusinessException("Latitude must be between -90 and 90");
            }
            location.setLatitude(request.getLatitude());
        }
        if (request.getLongitude() != null) {
            if (request.getLongitude() < -180 || request.getLongitude() > 180) {
                throw new me.devziyad.unipoolbackend.exception.BusinessException("Longitude must be between -180 and 180");
            }
            location.setLongitude(request.getLongitude());
        }
        if (request.getIsFavorite() != null) location.setIsFavorite(request.getIsFavorite());

        return toResponse(locationRepository.save(location));
    }

    @Override
    @Transactional
    public void deleteLocation(Long id, Long userId) {
        Location location = locationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Location not found"));

        if (location.getUser() != null && !location.getUser().getId().equals(userId)) {
            throw new ForbiddenException("You can only delete your own locations");
        }

        locationRepository.delete(location);
    }

    @Override
    public DistanceResponse calculateDistance(Long locationAId, Long locationBId) {
        Location a = locationRepository.findById(locationAId)
                .orElseThrow(() -> new ResourceNotFoundException("Location A not found"));
        Location b = locationRepository.findById(locationBId)
                .orElseThrow(() -> new ResourceNotFoundException("Location B not found"));

        double distanceKm = DistanceUtil.haversineDistance(
                a.getLatitude(), a.getLongitude(),
                b.getLatitude(), b.getLongitude()
        );

        RouteInfo routeInfo = routingService.getRouteInfo(
                a.getLatitude(), a.getLongitude(),
                b.getLatitude(), b.getLongitude()
        );

        return DistanceResponse.builder()
                .distanceKm(distanceKm)
                .estimatedDurationMinutes(routeInfo.getDurationMinutes())
                .build();
    }

    @Override
    public RouteInfo getRouteInfo(Long locationAId, Long locationBId) {
        Location a = locationRepository.findById(locationAId)
                .orElseThrow(() -> new ResourceNotFoundException("Location A not found"));
        Location b = locationRepository.findById(locationBId)
                .orElseThrow(() -> new ResourceNotFoundException("Location B not found"));

        return routingService.getRouteInfo(
                a.getLatitude(), a.getLongitude(),
                b.getLatitude(), b.getLongitude()
        );
    }

    @Override
    public List<Map<String, Object>> searchLocation(String query) {
        return geocodingService.searchLocation(query);
    }

    @Override
    public String reverseGeocode(Double latitude, Double longitude) {
        return geocodingService.reverseGeocode(latitude, longitude);
    }
}