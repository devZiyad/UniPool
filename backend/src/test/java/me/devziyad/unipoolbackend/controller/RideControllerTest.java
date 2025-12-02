package me.devziyad.unipoolbackend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import me.devziyad.unipoolbackend.UniPoolBackendApplication;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.location.LocationRepository;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
import me.devziyad.unipoolbackend.ride.dto.CreateRideRequest;
import me.devziyad.unipoolbackend.ride.dto.SearchRidesRequest;
import me.devziyad.unipoolbackend.security.JwtService;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import me.devziyad.unipoolbackend.vehicle.Vehicle;
import me.devziyad.unipoolbackend.vehicle.VehicleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

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
@ActiveProfiles("test")
@Transactional
class RideControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private LocationRepository locationRepository;

    @Autowired
    private RideRepository rideRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    private User driverUser;
    private Vehicle testVehicle;
    private Location pickupLocation;
    private Location destinationLocation;
    private Ride testRide;
    private String driverToken;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
        vehicleRepository.deleteAll();
        locationRepository.deleteAll();
        rideRepository.deleteAll();

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
        testRide = rideRepository.save(testRide);

        driverToken = jwtService.generateToken(driverUser.getId(), driverUser.getEmail());
    }

    @Test
    void testCreateRide_Success() throws Exception {
        CreateRideRequest request = new CreateRideRequest();
        request.setVehicleId(testVehicle.getId());
        request.setPickupLocationId(pickupLocation.getId());
        request.setDestinationLocationId(destinationLocation.getId());
        request.setDepartureTime(LocalDateTime.now().plusHours(3));
        request.setTotalSeats(4);

        mockMvc.perform(post("/api/rides")
                        .header("Authorization", "Bearer " + driverToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.driverId").value(driverUser.getId()))
                .andExpect(jsonPath("$.status").value("POSTED"));
    }

    @Test
    void testGetRide_Success() throws Exception {
        mockMvc.perform(get("/api/rides/" + testRide.getId())
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(testRide.getId()))
                .andExpect(jsonPath("$.driverId").value(driverUser.getId()));
    }

    @Test
    void testSearchRides_Success() throws Exception {
        SearchRidesRequest request = new SearchRidesRequest();
        request.setPickupLocationId(pickupLocation.getId());
        request.setDestinationLocationId(destinationLocation.getId());
        request.setMinAvailableSeats(1);

        mockMvc.perform(post("/api/rides/search")
                        .header("Authorization", "Bearer " + driverToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void testGetMyRidesAsDriver_Success() throws Exception {
        mockMvc.perform(get("/api/rides/me/driver")
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].driverId").value(driverUser.getId()));
    }

    @Test
    void testUpdateRideStatus_Success() throws Exception {
        mockMvc.perform(patch("/api/rides/" + testRide.getId() + "/status")
                        .header("Authorization", "Bearer " + driverToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"IN_PROGRESS\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("IN_PROGRESS"));
    }

    @Test
    void testCancelRide_Success() throws Exception {
        mockMvc.perform(delete("/api/rides/" + testRide.getId())
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk());
    }

    @Test
    void testGetAvailableSeats_Success() throws Exception {
        mockMvc.perform(get("/api/rides/" + testRide.getId() + "/available-seats")
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").value(3));
    }
}

