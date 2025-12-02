package me.devziyad.unipoolbackend.controller;

import me.devziyad.unipoolbackend.UniPoolBackendApplication;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.security.JwtService;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
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

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(classes = UniPoolBackendApplication.class)
@ActiveProfiles("test")
@Transactional
class AdminControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    private User adminUser;
    private User regularUser;
    private String adminToken;
    private String regularToken;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();

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

        regularUser = User.builder()
                .universityId("R123456")
                .email("regular@example.com")
                .passwordHash(passwordEncoder.encode("password123"))
                .fullName("Regular User")
                .role(Role.RIDER)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        regularUser = userRepository.save(regularUser);

        adminToken = jwtService.generateToken(adminUser.getId(), adminUser.getEmail());
        regularToken = jwtService.generateToken(regularUser.getId(), regularUser.getEmail());
    }

    @Test
    void testGetAllUsers_Admin() throws Exception {
        mockMvc.perform(get("/api/admin/users")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void testGetAllUsers_Forbidden() throws Exception {
        mockMvc.perform(get("/api/admin/users")
                        .header("Authorization", "Bearer " + regularToken))
                .andExpect(status().isForbidden());
    }

    @Test
    void testGetUser_Admin() throws Exception {
        mockMvc.perform(get("/api/admin/users/" + regularUser.getId())
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(regularUser.getId()));
    }

    @Test
    void testEnableUser_Admin() throws Exception {
        mockMvc.perform(put("/api/admin/users/" + regularUser.getId() + "/enable")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"enabled\":false}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.enabled").value(false));
    }

    @Test
    void testGetAllRides_Admin() throws Exception {
        mockMvc.perform(get("/api/admin/rides")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void testGetAllBookings_Admin() throws Exception {
        mockMvc.perform(get("/api/admin/bookings")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void testGetAllPayments_Admin() throws Exception {
        mockMvc.perform(get("/api/admin/payments")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }
}

