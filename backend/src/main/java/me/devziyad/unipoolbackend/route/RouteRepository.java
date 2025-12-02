package me.devziyad.unipoolbackend.route;

import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RouteRepository extends JpaRepository<@NonNull Route, @NonNull Long> {
    Optional<Route> findByRideId(Long rideId);
    @NonNull
    List<@NonNull Route> findByStopsId(Long locationId);
}

