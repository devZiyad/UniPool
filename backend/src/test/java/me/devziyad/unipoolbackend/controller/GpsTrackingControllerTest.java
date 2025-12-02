package me.devziyad.unipoolbackend.controller;

import me.devziyad.unipoolbackend.UniPoolBackendApplication;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.location.LocationRepository;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
import me.devziyad.unipoolbackend.security.JwtService;
import me.devziyad.unipoolbackend.tracking.GpsTracking;
import me.devziyad.unipoolbackend.tracking.GpsTrackingRepository;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import me.devziyad.unipoolbackend.vehicle.Vehicle;
import me.devziyad.unipoolbackend.vehicle.VehicleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(classes = UniPoolBackendApplication.class)
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class GpsTrackingControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private LocationRepository locationRepository;

    @Autowired
    private RideRepository rideRepository;

    @Autowired
    private GpsTrackingRepository trackingRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    private User driverUser;
    private User passengerUser;
    private Vehicle testVehicle;
    private Location pickupLocation;
    private Location destinationLocation;
    private Ride testRide;
    private GpsTracking testTracking;
    private String driverToken;
    private String passengerToken;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
        vehicleRepository.deleteAll();
        locationRepository.deleteAll();
        rideRepository.deleteAll();
        trackingRepository.deleteAll();

        driverUser = User.builder()
                .universityId("D123456")
                .email("driver@example.com")
                .passwordHash(passwordEncoder.encode("password123"))
                .fullName("Driver User")
                .role(Role.DRIVER)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        driverUser = userRepository.save(driverUser);

        passengerUser = User.builder()
                .universityId("P123456")
                .email("passenger@example.com")
                .passwordHash(passwordEncoder.encode("password123"))
                .fullName("Passenger User")
                .role(Role.RIDER)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        passengerUser = userRepository.save(passengerUser);

        testVehicle = Vehicle.builder()
                .make("Toyota")
                .model("Corolla")
                .seatCount(4)
                .plateNumber("ABC123")
                .owner(driverUser)
                .active(true)
                .build();
        testVehicle = vehicleRepository.save(testVehicle);

        pickupLocation = Location.builder()
                .label("Pickup")
                .latitude(33.8938)
                .longitude(35.5018)
                .user(driverUser)
                .build();
        pickupLocation = locationRepository.save(pickupLocation);

        destinationLocation = Location.builder()
                .label("Destination")
                .latitude(33.9000)
                .longitude(35.5100)
                .user(driverUser)
                .build();
        destinationLocation = locationRepository.save(destinationLocation);

        testRide = Ride.builder()
                .driver(driverUser)
                .vehicle(testVehicle)
                .pickupLocation(pickupLocation)
                .destinationLocation(destinationLocation)
                .departureTime(LocalDateTime.now().plusHours(1))
                .totalSeats(4)
                .availableSeats(2)
                .estimatedDistanceKm(10.5)
                .routeDistanceKm(11.0)
                .estimatedDurationMinutes(20)
                .basePrice(BigDecimal.valueOf(50.00))
                .pricePerSeat(BigDecimal.valueOf(12.50))
                .status(RideStatus.IN_PROGRESS)
                .build();
        testRide = rideRepository.save(testRide);

        testTracking = GpsTracking.builder()
                .ride(testRide)
                .latitude(33.8938)
                .longitude(35.5018)
                .isActive(true)
                .build();
        testTracking = trackingRepository.save(testTracking);

        driverToken = jwtService.generateToken(driverUser.getId(), driverUser.getEmail());
        passengerToken = jwtService.generateToken(passengerUser.getId(), passengerUser.getEmail());
    }

    @Test
    void testUpdateLocation_Success() throws Exception {
        mockMvc.perform(post("/api/tracking/" + testRide.getId() + "/update")
                        .header("Authorization", "Bearer " + driverToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"latitude\":33.9000,\"longitude\":35.5100}"))
                .andExpect(status().isOk());
    }

    @Test
    void testUpdateLocation_Forbidden() throws Exception {
        mockMvc.perform(post("/api/tracking/" + testRide.getId() + "/update")
                        .header("Authorization", "Bearer " + passengerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"latitude\":33.9000,\"longitude\":35.5100}"))
                .andExpect(status().isForbidden());
    }

    @Test
    void testGetCurrentLocation_Success() throws Exception {
        mockMvc.perform(get("/api/tracking/" + testRide.getId())
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.rideId").value(testRide.getId()))
                .andExpect(jsonPath("$.latitude").value(33.8938));
    }

    @Test
    void testStartTracking_Success() throws Exception {
        mockMvc.perform(post("/api/tracking/" + testRide.getId() + "/start")
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk());
    }

    @Test
    void testStopTracking_Success() throws Exception {
        mockMvc.perform(post("/api/tracking/" + testRide.getId() + "/stop")
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk());
    }
}

