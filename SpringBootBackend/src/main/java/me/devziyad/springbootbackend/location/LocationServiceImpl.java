package me.devziyad.springbootbackend.location;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LocationServiceImpl implements LocationService {

    private final LocationRepository locationRepository;

    @Override
    public Location createLocation(Location location) {
        return locationRepository.save(location);
    }

    @Override
    public Location getLocation(Long id) {
        return locationRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Location not found"));
    }

    @Override
    public List<Location> getAllLocations() {
        return locationRepository.findAll();
    }

    @Override
    public double distanceKm(Location a, Location b) {
        if (a.getLatitude() == null || a.getLongitude() == null ||
                b.getLatitude() == null || b.getLongitude() == null) {
            return -1;
        }
        return haversine(a.getLatitude(), a.getLongitude(), b.getLatitude(), b.getLongitude());
    }

    private double haversine(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // km
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double x = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) *
                        Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(x), Math.sqrt(1 - x));
        return R * c;
    }
}