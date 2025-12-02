package me.devziyad.unipoolbackend.tracking;

import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GpsTrackingRepository extends JpaRepository<@NonNull GpsTracking, @NonNull Long> {
    Optional<GpsTracking> findByRideId(Long rideId);
}

