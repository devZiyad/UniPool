package me.devziyad.unipoolbackend.tracking;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
import me.devziyad.unipoolbackend.tracking.dto.GpsLocationResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class GpsTrackingServiceImpl implements GpsTrackingService {

    private final GpsTrackingRepository trackingRepository;
    private final RideRepository rideRepository;

    @Override
    @Transactional
    public void updateLocation(Long rideId, Double latitude, Double longitude) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));

        GpsTracking tracking = trackingRepository.findByRideId(rideId)
                .orElseGet(() -> {
                    GpsTracking newTracking = GpsTracking.builder()
                            .ride(ride)
                            .latitude(latitude)
                            .longitude(longitude)
                            .isActive(false)
                            .build();
                    return trackingRepository.save(newTracking);
                });

        tracking.setLatitude(latitude);
        tracking.setLongitude(longitude);
        tracking.setLastUpdate(LocalDateTime.now());
        trackingRepository.save(tracking);
    }

    @Override
    public GpsLocationResponse getCurrentLocation(Long rideId) {
        GpsTracking tracking = trackingRepository.findByRideId(rideId)
                .orElseThrow(() -> new ResourceNotFoundException("Tracking not found for this ride"));

        return GpsLocationResponse.builder()
                .rideId(rideId)
                .latitude(tracking.getLatitude())
                .longitude(tracking.getLongitude())
                .lastUpdate(tracking.getLastUpdate())
                .isActive(tracking.getIsActive())
                .build();
    }

    @Override
    @Transactional
    public void startTracking(Long rideId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));

        GpsTracking tracking = trackingRepository.findByRideId(rideId)
                .orElseGet(() -> {
                    GpsTracking newTracking = GpsTracking.builder()
                            .ride(ride)
                            .isActive(true)
                            .build();
                    return trackingRepository.save(newTracking);
                });

        tracking.setIsActive(true);
        tracking.setLastUpdate(LocalDateTime.now());
        trackingRepository.save(tracking);
    }

    @Override
    @Transactional
    public void stopTracking(Long rideId) {
        GpsTracking tracking = trackingRepository.findByRideId(rideId)
                .orElseThrow(() -> new ResourceNotFoundException("Tracking not found"));

        tracking.setIsActive(false);
        trackingRepository.save(tracking);
    }
}

