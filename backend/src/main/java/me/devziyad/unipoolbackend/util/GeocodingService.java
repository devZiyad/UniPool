package me.devziyad.unipoolbackend.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.http.client.ClientHttpRequestInterceptor;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class GeocodingService {

    private static final Logger logger = LoggerFactory.getLogger(GeocodingService.class);
    private static final String NOMINATIM_BASE_URL = "https://nominatim.openstreetmap.org";
    private static final String NOMINATIM_SEARCH_URL = NOMINATIM_BASE_URL + "/search";
    private static final String NOMINATIM_REVERSE_URL = NOMINATIM_BASE_URL + "/reverse";
    private final RestTemplate restTemplate;
    private final String countryCodes;

    public GeocodingService(@Value("${geocoding.country-codes:}") String countryCodes) {
        this.restTemplate = new RestTemplate();
        // Set user agent to avoid 403
        List<ClientHttpRequestInterceptor> interceptors = new ArrayList<>();
        interceptors.add((request, body, execution) -> {
            request.getHeaders().set("User-Agent", "UniPool/1.0");
            return execution.execute(request, body);
        });
        restTemplate.setInterceptors(interceptors);
        this.countryCodes = countryCodes != null && !countryCodes.trim().isEmpty() ? countryCodes.trim() : null;
    }

    /**
     * Search for locations by query string
     */
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> searchLocation(String query) {
        try {
            StringBuilder urlBuilder = new StringBuilder();
            urlBuilder.append(String.format("%s?q=%s&format=json&limit=5&accept-language=en",
                    NOMINATIM_SEARCH_URL, query.replace(" ", "+")));
            
            // Add country code filter if configured
            if (countryCodes != null) {
                urlBuilder.append("&countrycodes=").append(countryCodes);
            }
            
            String url = urlBuilder.toString();
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
     * Results are cached to avoid repeated API calls for the same coordinates.
     * Coordinates are rounded to 6 decimal places (~0.1 meter precision) for cache key.
     */
    @SuppressWarnings("unchecked")
    @Cacheable(value = "reverseGeocode", 
               key = "T(java.lang.String).format('%.6f_%.6f', #lat, #lon)", 
               unless = "#result == null")
    public String reverseGeocode(double lat, double lon) {
        // Round coordinates to 6 decimal places (~0.1 meter precision) for consistent caching
        // This prevents cache misses due to floating point precision differences
        double roundedLat = Math.round(lat * 1000000.0) / 1000000.0;
        double roundedLon = Math.round(lon * 1000000.0) / 1000000.0;
        
        try {
            logger.debug("Reverse geocoding coordinates: lat={}, lon={} (rounded from lat={}, lon={})", 
                    roundedLat, roundedLon, lat, lon);
            
            // Nominatim reverse geocoding returns a single object, not a list
            String url = String.format("%s?lat=%s&lon=%s&format=json&accept-language=en",
                    NOMINATIM_REVERSE_URL, roundedLat, roundedLon);

            Object response = restTemplate.getForObject(url, Object.class);
            if (response instanceof Map<?, ?> resultMap) {
                Map<String, Object> result = (Map<String, Object>) resultMap;
                Object displayName = result.get("display_name");
                if (displayName != null) {
                    String address = displayName.toString();
                    logger.debug("Reverse geocoded address: {}", address);
                    return address;
                }
            }
        } catch (Exception e) {
            logger.warn("Failed to reverse geocode: {}", e.getMessage());
        }
        return null;
    }
}