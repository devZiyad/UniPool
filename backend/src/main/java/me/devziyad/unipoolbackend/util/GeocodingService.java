package me.devziyad.unipoolbackend.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.client.ClientHttpRequestInterceptor;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class GeocodingService {

    private static final Logger logger = LoggerFactory.getLogger(GeocodingService.class);
    private static final String NOMINATIM_BASE_URL = "https://nominatim.openstreetmap.org/search";
    private final RestTemplate restTemplate;

    public GeocodingService() {
        this.restTemplate = new RestTemplate();
        // Set user agent to avoid 403
        List<ClientHttpRequestInterceptor> interceptors = new ArrayList<>();
        interceptors.add((request, body, execution) -> {
            request.getHeaders().set("User-Agent", "UniPool/1.0");
            return execution.execute(request, body);
        });
        restTemplate.setInterceptors(interceptors);
    }

    /**
     * Search for locations by query string
     */
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> searchLocation(String query) {
        try {
            String url = String.format("%s?q=%s&format=json&limit=5",
                    NOMINATIM_BASE_URL, query.replace(" ", "+"));

            Object response = restTemplate.getForObject(url, Object.class);
            if (response instanceof List<?> results) {
                return (List<Map<String, Object>>) results;
            }
            return List.of();
        } catch (Exception e) {
            logger.warn("Failed to geocode location: {}", e.getMessage());
            return List.of();
        }
    }

    /**
     * Reverse geocode: get address from coordinates
     */
    @SuppressWarnings("unchecked")
    public String reverseGeocode(double lat, double lon) {
        try {
            String url = String.format("%s?lat=%s&lon=%s&format=json",
                    NOMINATIM_BASE_URL, lat, lon);

            Object response = restTemplate.getForObject(url, Object.class);
            if (response instanceof List<?> results && !results.isEmpty()) {
                Object firstResult = results.get(0);
                if (firstResult instanceof Map<?, ?> resultMap) {
                    Map<String, Object> result = (Map<String, Object>) resultMap;
                    Object displayName = result.get("display_name");
                    return displayName != null ? displayName.toString() : null;
                }
            }
        } catch (Exception e) {
            logger.warn("Failed to reverse geocode: {}", e.getMessage());
        }
        return null;
    }
}