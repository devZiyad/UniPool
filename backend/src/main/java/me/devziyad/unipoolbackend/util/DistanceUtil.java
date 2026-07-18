package me.devziyad.unipoolbackend.util;

public class DistanceUtil {

    private static final double EARTH_RADIUS_KM = 6371.0;

    /**
     * Calculate distance between two coordinates using Haversine formula
     * @return distance in kilometers
     */
    public static double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS_KM * c;
    }

    /**
     * Check if a point is within radius of another point
     */
    public static boolean isWithinRadius(double lat1, double lon1, double lat2, double lon2, double radiusKm) {
        return haversineDistance(lat1, lon1, lat2, lon2) <= radiusKm;
    }
}