package me.devziyad.springbootbackend.location;

import java.util.List;

public interface LocationService {

    Location createLocation(Location location);

    Location getLocation(Long id);

    List<Location> getAllLocations();

    double distanceKm(Location a, Location b);
}