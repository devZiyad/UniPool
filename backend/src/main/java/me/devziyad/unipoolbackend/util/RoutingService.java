package me.devziyad.unipoolbackend.util;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
public class RoutingService {

    private static final Logger logger = LoggerFactory.getLogger(RoutingService.class);
    private static final String OSRM_BASE_URL = "http://router.project-osrm.org/route/v1/driving/";
    private static final int CONNECTION_TIMEOUT_MS = 2000; // 2 seconds
    private static final int READ_TIMEOUT_MS = 3000; // 3 seconds
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    public RoutingService() {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(CONNECTION_TIMEOUT_MS);
        factory.setReadTimeout(READ_TIMEOUT_MS);
        this.restTemplate = new RestTemplate(factory);
        this.objectMapper = new ObjectMapper();
    }

    /**
     * Get route information from OSRM
     * Returns distance in km and duration in minutes
     * 
     * According to OSRM API docs:
     * - Coordinates format: {longitude},{latitude};{longitude},{latitude}
     * - Response contains 'code' field: "Ok" for success, error codes otherwise
     * - When geometries=geojson, geometry is a GeoJSON LineString object
     * - Distance is in meters, duration is in seconds
     */
    @SuppressWarnings("unchecked")
    public RouteInfo getRouteInfo(double lat1, double lon1, double lat2, double lon2) {
        try {
            // OSRM API format: longitude,latitude;longitude,latitude
            String url = String.format("%s%s,%s;%s,%s?overview=full&geometries=geojson",
                    OSRM_BASE_URL, lon1, lat1, lon2, lat2);

            Map<String, Object> response = restTemplate.getForObject(url, Map.class);

            if (response == null) {
                logger.warn("OSRM returned null response, using Haversine fallback");
                return createHaversineFallback(lat1, lon1, lat2, lon2);
            }

            // Check response code according to OSRM API spec
            Object codeObj = response.get("code");
            if (codeObj != null && !"Ok".equals(codeObj.toString())) {
                String message = response.containsKey("message") 
                    ? response.get("message").toString() 
                    : "Unknown error";
                logger.warn("OSRM returned error code '{}': {}, using Haversine fallback", codeObj, message);
                return createHaversineFallback(lat1, lon1, lat2, lon2);
            }

            // Parse routes array
            if (!response.containsKey("routes")) {
                logger.warn("OSRM response missing 'routes' field, using Haversine fallback");
                return createHaversineFallback(lat1, lon1, lat2, lon2);
            }

                Object routesObj = response.get("routes");
            if (!(routesObj instanceof List<?> routesList) || routesList.isEmpty()) {
                logger.warn("OSRM response has empty or invalid routes array, using Haversine fallback");
                return createHaversineFallback(lat1, lon1, lat2, lon2);
            }

                    Object firstRoute = routesList.get(0);
            if (!(firstRoute instanceof Map<?, ?>)) {
                logger.warn("OSRM route object is not a map, using Haversine fallback");
                return createHaversineFallback(lat1, lon1, lat2, lon2);
            }

            Map<String, Object> route = (Map<String, Object>) firstRoute;

                        Object distanceObj = route.get("distance");
                        Object durationObj = route.get("duration");

            if (!(distanceObj instanceof Number) || !(durationObj instanceof Number)) {
                logger.warn("OSRM route missing distance or duration, using Haversine fallback");
                return createHaversineFallback(lat1, lon1, lat2, lon2);
            }

                            double distanceMeters = ((Number) distanceObj).doubleValue();
                            double durationSeconds = ((Number) durationObj).doubleValue();

            // Extract geometry - when geometries=geojson, it's a GeoJSON LineString object
            // We'll serialize it to JSON string for storage
            String polyline = null;
                            Object geometryObj = route.get("geometry");
            if (geometryObj != null) {
                try {
                    // Serialize GeoJSON geometry to JSON string
                    polyline = objectMapper.writeValueAsString(geometryObj);
                } catch (Exception e) {
                    logger.debug("Failed to serialize geometry to JSON: {}", e.getMessage());
                    polyline = geometryObj.toString();
                }
            }

                            return new RouteInfo(
                                    distanceMeters / 1000.0, // convert to km
                    (int) Math.round(durationSeconds / 60.0), // convert to minutes, rounded
                                    polyline
                            );

        } catch (ResourceAccessException e) {
            // Timeout or connection error
            logger.warn("OSRM request timeout or connection error ({}), using Haversine fallback", 
                    e.getMessage());
            return createHaversineFallback(lat1, lon1, lat2, lon2);
        } catch (RestClientException e) {
            // Other HTTP errors
            logger.warn("OSRM HTTP error ({}), using Haversine fallback", e.getMessage());
            return createHaversineFallback(lat1, lon1, lat2, lon2);
        } catch (Exception e) {
            logger.warn("Unexpected error calling OSRM ({}), using Haversine fallback", e.getMessage());
            return createHaversineFallback(lat1, lon1, lat2, lon2);
        }
        }

    /**
     * Create fallback RouteInfo using Haversine distance calculation
     */
    private RouteInfo createHaversineFallback(double lat1, double lon1, double lat2, double lon2) {
        double distanceKm = DistanceUtil.haversineDistance(lat1, lon1, lat2, lon2);
        // Rough estimate: 40 km/h average speed
        int durationMinutes = (int) Math.round(distanceKm * 1.5);
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