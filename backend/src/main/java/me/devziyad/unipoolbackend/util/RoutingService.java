package me.devziyad.unipoolbackend.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
public class RoutingService {

    private static final Logger logger = LoggerFactory.getLogger(RoutingService.class);
    private static final String OSRM_BASE_URL = "http://router.project-osrm.org/route/v1/driving/";
    private final RestTemplate restTemplate;

    public RoutingService() {
        this.restTemplate = new RestTemplate();
    }

    /**
     * Get route information from OSRM
     * Returns distance in km and duration in minutes
     */
    @SuppressWarnings("unchecked")
    public RouteInfo getRouteInfo(double lat1, double lon1, double lat2, double lon2) {
        try {
            String url = String.format("%s%s,%s;%s,%s?overview=full&geometries=geojson",
                    OSRM_BASE_URL, lon1, lat1, lon2, lat2);

            Map<String, Object> response = restTemplate.getForObject(url, Map.class);

            if (response != null && response.containsKey("routes")) {
                Object routesObj = response.get("routes");
                if (routesObj instanceof List<?> routesList && !routesList.isEmpty()) {
                    Object firstRoute = routesList.get(0);
                    if (firstRoute instanceof Map<?, ?> routeMap) {
                        Map<String, Object> route = (Map<String, Object>) routeMap;

                        Object distanceObj = route.get("distance");
                        Object durationObj = route.get("duration");

                        if (distanceObj instanceof Number && durationObj instanceof Number) {
                            double distanceMeters = ((Number) distanceObj).doubleValue();
                            double durationSeconds = ((Number) durationObj).doubleValue();

                            Object geometryObj = route.get("geometry");
                            String polyline = geometryObj != null ? geometryObj.toString() : null;

                            return new RouteInfo(
                                    distanceMeters / 1000.0, // convert to km
                                    (int) (durationSeconds / 60.0), // convert to minutes
                                    polyline
                            );
                        }
                    }
                }
            }
        } catch (Exception e) {
            logger.warn("Failed to get route from OSRM, using Haversine: {}", e.getMessage());
        }

        // Fallback to Haversine
        double distanceKm = DistanceUtil.haversineDistance(lat1, lon1, lat2, lon2);
        int durationMinutes = (int) (distanceKm * 1.5); // Rough estimate: 40 km/h average

        return new RouteInfo(distanceKm, durationMinutes, null);
    }

    public static class RouteInfo {
        private final double distanceKm;
        private final int durationMinutes;
        private final String polyline;

        public RouteInfo(double distanceKm, int durationMinutes, String polyline) {
            this.distanceKm = distanceKm;
            this.durationMinutes = durationMinutes;
            this.polyline = polyline;
        }

        public double getDistanceKm() {
            return distanceKm;
        }

        public int getDurationMinutes() {
            return durationMinutes;
        }

        public String getPolyline() {
            return polyline;
        }
    }
}