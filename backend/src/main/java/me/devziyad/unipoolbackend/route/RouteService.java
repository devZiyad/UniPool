package me.devziyad.unipoolbackend.route;

import me.devziyad.unipoolbackend.route.dto.CreateRouteRequest;
import me.devziyad.unipoolbackend.route.dto.RouteResponse;
import me.devziyad.unipoolbackend.route.dto.UpdateRouteRequest;

import java.util.List;

public interface RouteService {
    RouteResponse createRoute(CreateRouteRequest request, Long userId);
    RouteResponse getRouteById(Long id);
    RouteResponse updateRoute(Long id, UpdateRouteRequest request, Long userId);
    List<RouteResponse> getMyRoutes(Long userId);
}

