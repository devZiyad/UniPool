package me.devziyad.unipoolbackend.route;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RouteRepository extends JpaRepository<Route, Long> {
    Optional<Route> findByRideId(Long rideId);
    List<Route> findByStopsId(Long locationId);
}

