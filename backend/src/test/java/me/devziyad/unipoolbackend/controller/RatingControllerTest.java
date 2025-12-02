package me.devziyad.unipoolbackend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import me.devziyad.unipoolbackend.UniPoolBackendApplication;
import me.devziyad.unipoolbackend.booking.Booking;
import me.devziyad.unipoolbackend.booking.BookingRepository;
import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.location.LocationRepository;
import me.devziyad.unipoolbackend.rating.dto.CreateRatingRequest;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
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
class RatingControllerTest {

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
    private BookingRepository bookingRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    private User driverUser;
    private User riderUser;
    private Vehicle testVehicle;
    private Location pickupLocation;
    private Location destinationLocation;
    private Ride testRide;
    private Booking testBooking;
    private String driverToken;
    private String riderToken;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
        vehicleRepository.deleteAll();
        locationRepository.deleteAll();
        rideRepository.deleteAll();
        bookingRepository.deleteAll();

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

        riderUser = User.builder()
                .universityId("R123456")
                .email("rider@example.com")
                .passwordHash(passwordEncoder.encode("password123"))
                .fullName("Rider User")
                .role(Role.RIDER)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        riderUser = userRepository.save(riderUser);

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
                .departureTime(LocalDateTime.now().minusHours(1))
                .totalSeats(4)
                .availableSeats(0)
                .estimatedDistanceKm(10.5)
                .routeDistanceKm(11.0)
                .estimatedDurationMinutes(20)
                .basePrice(BigDecimal.valueOf(50.00))
                .pricePerSeat(BigDecimal.valueOf(12.50))
                .status(RideStatus.COMPLETED)
                .build();
        testRide = rideRepository.save(testRide);

        testBooking = Booking.builder()
                .ride(testRide)
                .rider(riderUser)
                .seatsBooked(2)
                .status(BookingStatus.COMPLETED)
                .costForThisRider(BigDecimal.valueOf(25.00))
                .build();
        testBooking = bookingRepository.save(testBooking);

        driverToken = jwtService.generateToken(driverUser.getId(), driverUser.getEmail());
        riderToken = jwtService.generateToken(riderUser.getId(), riderUser.getEmail());
    }

    @Test
    void testCreateRating_Success() throws Exception {
        CreateRatingRequest request = new CreateRatingRequest();
        request.setBookingId(testBooking.getId());
        request.setScore(5);
        request.setComment("Great ride!");

        mockMvc.perform(post("/api/ratings")
                        .header("Authorization", "Bearer " + riderToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.score").value(5))
                .andExpect(jsonPath("$.fromUserId").value(riderUser.getId()))
                .andExpect(jsonPath("$.toUserId").value(driverUser.getId()));
    }

    @Test
    void testCreateRating_InvalidScore() throws Exception {
        CreateRatingRequest request = new CreateRatingRequest();
        request.setBookingId(testBooking.getId());
        request.setScore(10); // Invalid score

        mockMvc.perform(post("/api/ratings")
                        .header("Authorization", "Bearer " + riderToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testCreateRating_NotCompletedBooking() throws Exception {
        Booking pendingBooking = Booking.builder()
                .ride(testRide)
                .rider(riderUser)
                .seatsBooked(1)
                .status(BookingStatus.CONFIRMED)
                .costForThisRider(BigDecimal.valueOf(12.50))
                .build();
        pendingBooking = bookingRepository.save(pendingBooking);

        CreateRatingRequest request = new CreateRatingRequest();
        request.setBookingId(pendingBooking.getId());
        request.setScore(5);

        mockMvc.perform(post("/api/ratings")
                        .header("Authorization", "Bearer " + riderToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testGetRatingsForUser_Success() throws Exception {
        mockMvc.perform(get("/api/ratings/user/" + driverUser.getId())
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void testGetRatingsByMe_Success() throws Exception {
        mockMvc.perform(get("/api/ratings/me/given")
                        .header("Authorization", "Bearer " + riderToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }
}

