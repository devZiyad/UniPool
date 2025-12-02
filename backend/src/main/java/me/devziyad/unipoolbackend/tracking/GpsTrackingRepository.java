package me.devziyad.unipoolbackend.tracking;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface GpsTrackingRepository extends JpaRepository<GpsTracking, Long> {
    Optional<GpsTracking> findByRideId(Long rideId);
}

