package me.devziyad.unipoolbackend.controller;

import me.devziyad.unipoolbackend.UniPoolBackendApplication;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.security.JwtService;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(classes = UniPoolBackendApplication.class)
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class AnalyticsControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    private User driverUser;
    private User riderUser;
    private User adminUser;
    private String driverToken;
    private String riderToken;
    private String adminToken;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();

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

        adminUser = User.builder()
                .universityId("A123456")
                .email("admin@example.com")
                .passwordHash(passwordEncoder.encode("password123"))
                .fullName("Admin User")
                .role(Role.ADMIN)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        adminUser = userRepository.save(adminUser);

        driverToken = jwtService.generateToken(driverUser.getId(), driverUser.getEmail());
        riderToken = jwtService.generateToken(riderUser.getId(), riderUser.getEmail());
        adminToken = jwtService.generateToken(adminUser.getId(), adminUser.getEmail());
    }

    @Test
    void testGetDriverEarnings_Success() throws Exception {
        mockMvc.perform(get("/api/analytics/driver/earnings")
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.driverId").value(driverUser.getId()));
    }

    @Test
    void testGetRiderSpending_Success() throws Exception {
        mockMvc.perform(get("/api/analytics/rider/spending")
                        .header("Authorization", "Bearer " + riderToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.riderId").value(riderUser.getId()));
    }

    @Test
    void testGetRideStats_Success() throws Exception {
        mockMvc.perform(get("/api/analytics/rides/stats")
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalRides").exists());
    }

    @Test
    void testGetBookingStats_Admin() throws Exception {
        mockMvc.perform(get("/api/analytics/bookings/stats")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalBookings").exists());
    }

    @Test
    void testGetBookingStats_Forbidden() throws Exception {
        mockMvc.perform(get("/api/analytics/bookings/stats")
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isForbidden());
    }

    @Test
    void testGetPopularDestinations_Admin() throws Exception {
        mockMvc.perform(get("/api/analytics/destinations/popular")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.destinations").exists());
    }

    @Test
    void testGetPeakTimes_Admin() throws Exception {
        mockMvc.perform(get("/api/analytics/times/peak")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.peakTimes").exists());
    }

    @Test
    void testGetDashboardStats_Admin() throws Exception {
        mockMvc.perform(get("/api/analytics/dashboard")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalUsers").exists())
                .andExpect(jsonPath("$.totalRides").exists());
    }
}

