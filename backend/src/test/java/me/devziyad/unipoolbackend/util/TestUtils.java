package me.devziyad.unipoolbackend.util;

import com.fasterxml.jackson.databind.ObjectMapper;
import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.vehicle.Vehicle;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class TestUtils {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    public static ObjectMapper getObjectMapper() {
        return objectMapper;
    }

    public static String toJson(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            throw new RuntimeException("Failed to convert object to JSON", e);
        }
    }

    public static <T> T fromJson(String json, Class<T> clazz) {
        try {
            return objectMapper.readValue(json, clazz);
        } catch (Exception e) {
            throw new RuntimeException("Failed to convert JSON to object", e);
        }
    }

    public static User createTestUser(String email, Role role) {
        return User.builder()
                .universityId("S" + System.currentTimeMillis())
                .email(email)
                .passwordHash("$2a$10$encodedPassword")
                .fullName("Test User")
                .phoneNumber("1234567890")
                .role(role)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
    }

    public static User createTestUser(Long id, String email, Role role) {
        User user = createTestUser(email, role);
        user.setId(id);
        return user;
    }

    public static Vehicle createTestVehicle(User owner) {
        return Vehicle.builder()
                .make("Toyota")
                .model("Corolla")
                .color("Blue")
                .plateNumber("ABC" + System.currentTimeMillis())
                .seatCount(4)
                .owner(owner)
                .active(true)
                .build();
    }

    public static Location createTestLocation(User user, String label) {
        return Location.builder()
                .label(label)
                .address("123 Test St")
                .latitude(33.8938)
                .longitude(35.5018)
                .user(user)
                .isFavorite(false)
                .build();
    }

    public static Ride createTestRide(User driver, Vehicle vehicle, Location pickup, Location destination) {
        return Ride.builder()
                .driver(driver)
                .vehicle(vehicle)
                .pickupLocation(pickup)
                .destinationLocation(destination)
                .departureTime(LocalDateTime.now().plusHours(2))
                .totalSeats(4)
                .availableSeats(3)
                .estimatedDistanceKm(10.5)
                .routeDistanceKm(11.0)
                .estimatedDurationMinutes(20)
                .basePrice(BigDecimal.valueOf(50.00))
                .pricePerSeat(BigDecimal.valueOf(12.50))
                .status(RideStatus.POSTED)
                .build();
    }
}

