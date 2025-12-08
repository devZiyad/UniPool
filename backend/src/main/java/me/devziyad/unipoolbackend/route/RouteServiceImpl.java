package me.devziyad.unipoolbackend.route;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.exception.BusinessException;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.route.dto.CreateRouteRequest;
import me.devziyad.unipoolbackend.route.dto.RouteResponse;
import me.devziyad.unipoolbackend.route.dto.UpdateRouteRequest;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import me.devziyad.unipoolbackend.util.RoutingService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RouteServiceImpl implements RouteService {

    private final RouteRepository routeRepository;
    private final UserRepository userRepository;
    private final RoutingService routingService;

    private RouteResponse toResponse(Route route) {
        return RouteResponse.builder()
                .routeId(route.getId())
                .createdByUserId(route.getCreatedBy().getId())
                .createdByName(route.getCreatedBy().getFullName())
                .startLatitude(route.getStartLatitude())
                .startLongitude(route.getStartLongitude())
                .endLatitude(route.getEndLatitude())
                .endLongitude(route.getEndLongitude())
                .distanceKm(route.getDistanceKm())
                .estimatedDurationMinutes(route.getEstimatedDurationMinutes())
                .polyline(route.getPolyline())
                .createdAt(route.getCreatedAt())
                .updatedAt(route.getUpdatedAt())
                .build();
    }

    @Override
    @Transactional
    public RouteResponse createRoute(CreateRouteRequest request, Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Validate coordinates
        if (request.getStartLatitude() == null || request.getStartLongitude() == null ||
            request.getEndLatitude() == null || request.getEndLongitude() == null) {
            throw new BusinessException("All coordinates are required");
        }

        // Validate coordinate ranges
        if (request.getStartLatitude() < -90 || request.getStartLatitude() > 90 ||
            request.getEndLatitude() < -90 || request.getEndLatitude() > 90) {
            throw new BusinessException("Latitude must be between -90 and 90");
        }

        if (request.getStartLongitude() < -180 || request.getStartLongitude() > 180 ||
            request.getEndLongitude() < -180 || request.getEndLongitude() > 180) {
            throw new BusinessException("Longitude must be between -180 and 180");
        }

        // Calculate distance and route using OSRM
        RoutingService.RouteInfo routeInfo = routingService.getRouteInfo(
                request.getStartLatitude(), request.getStartLongitude(),
                request.getEndLatitude(), request.getEndLongitude()
        );

        // Validate distance is reasonable
        if (routeInfo.getDistanceKm() < 0) {
            throw new BusinessException("Invalid route distance");
        }
        if (routeInfo.getDistanceKm() > 10000) { // 10,000 km max
            throw new BusinessException("Route distance exceeds maximum allowed distance");
        }

        Route route = Route.builder()
                .createdBy(user)
                .startLatitude(request.getStartLatitude())
                .startLongitude(request.getStartLongitude())
                .endLatitude(request.getEndLatitude())
                .endLongitude(request.getEndLongitude())
                .distanceKm(routeInfo.getDistanceKm())
                .estimatedDurationMinutes(routeInfo.getDurationMinutes())
                .polyline(routeInfo.getPolyline())
                .build();

        route = routeRepository.save(route);

        return toResponse(route);
    }

    @Override
    @Transactional(readOnly = true)
    public RouteResponse getRouteById(Long id) {
        Route route = routeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Route not found"));
        return toResponse(route);
    }

    @Override
    @Transactional
    public RouteResponse updateRoute(Long id, UpdateRouteRequest request, Long userId) {
        Route route = routeRepository.findByIdAndCreatedById(id, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Route not found or you don't have permission to update it"));

        boolean needsRecalculation = false;

        // Update coordinates if provided
        if (request.getStartLatitude() != null) {
            if (request.getStartLatitude() < -90 || request.getStartLatitude() > 90) {
                throw new BusinessException("Start latitude must be between -90 and 90");
            }
            route.setStartLatitude(request.getStartLatitude());
            needsRecalculation = true;
        }

        if (request.getStartLongitude() != null) {
            if (request.getStartLongitude() < -180 || request.getStartLongitude() > 180) {
                throw new BusinessException("Start longitude must be between -180 and 180");
            }
            route.setStartLongitude(request.getStartLongitude());
            needsRecalculation = true;
        }

        if (request.getEndLatitude() != null) {
            if (request.getEndLatitude() < -90 || request.getEndLatitude() > 90) {
                throw new BusinessException("End latitude must be between -90 and 90");
            }
            route.setEndLatitude(request.getEndLatitude());
            needsRecalculation = true;
        }

        if (request.getEndLongitude() != null) {
            if (request.getEndLongitude() < -180 || request.getEndLongitude() > 180) {
                throw new BusinessException("End longitude must be between -180 and 180");
            }
            route.setEndLongitude(request.getEndLongitude());
            needsRecalculation = true;
        }

        // Recalculate route if coordinates changed
        if (needsRecalculation) {
            RoutingService.RouteInfo routeInfo = routingService.getRouteInfo(
                    route.getStartLatitude(), route.getStartLongitude(),
                    route.getEndLatitude(), route.getEndLongitude()
            );

            route.setDistanceKm(routeInfo.getDistanceKm());
            route.setEstimatedDurationMinutes(routeInfo.getDurationMinutes());
            route.setPolyline(routeInfo.getPolyline());
        }

        route.setUpdatedAt(java.time.Instant.now());
        route = routeRepository.save(route);

        return toResponse(route);
    }

    @Override
    @Transactional(readOnly = true)
    public List<RouteResponse> getMyRoutes(Long userId) {
        return routeRepository.findByCreatedById(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }
}

