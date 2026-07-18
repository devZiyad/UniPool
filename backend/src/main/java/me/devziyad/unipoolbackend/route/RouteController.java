package me.devziyad.unipoolbackend.route;

import jakarta.validation.Valid;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.route.dto.CreateRouteRequest;
import me.devziyad.unipoolbackend.route.dto.RouteResponse;
import me.devziyad.unipoolbackend.route.dto.UpdateRouteRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/locations")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class RouteController {

    private final RouteService routeService;
    private final AuthService authService;

    @PostMapping("/route")
    public ResponseEntity<@NonNull RouteResponse> createRoute(@Valid @RequestBody CreateRouteRequest request) {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(routeService.createRoute(request, userId));
    }

    @GetMapping("/route/{id}")
    public ResponseEntity<@NonNull RouteResponse> getRoute(@PathVariable Long id) {
        return ResponseEntity.ok(routeService.getRouteById(id));
    }

    @PutMapping("/route/{id}")
    public ResponseEntity<@NonNull RouteResponse> updateRoute(
            @PathVariable Long id,
            @Valid @RequestBody UpdateRouteRequest request) {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(routeService.updateRoute(id, request, userId));
    }

    @GetMapping("/route/me")
    public ResponseEntity<@NonNull List<@NonNull RouteResponse>> getMyRoutes() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(routeService.getMyRoutes(userId));
    }
}

