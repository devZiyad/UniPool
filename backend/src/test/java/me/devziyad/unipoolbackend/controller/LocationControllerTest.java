package me.devziyad.unipoolbackend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import me.devziyad.unipoolbackend.UniPoolBackendApplication;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.location.LocationRepository;
import me.devziyad.unipoolbackend.location.dto.CreateLocationRequest;
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
class LocationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private LocationRepository locationRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    private User testUser;
    private Location testLocation;
    private String authToken;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
        locationRepository.deleteAll();

        testUser = User.builder()
                .universityId("S123456")
                .email("test@example.com")
                .passwordHash(passwordEncoder.encode("password123"))
                .fullName("Test User")
                .role(Role.RIDER)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        testUser = userRepository.save(testUser);

        testLocation = Location.builder()
                .label("Home")
                .address("123 Main St")
                .latitude(33.8938)
                .longitude(35.5018)
                .user(testUser)
                .isFavorite(true)
                .build();
        testLocation = locationRepository.save(testLocation);

        authToken = jwtService.generateToken(testUser.getId(), testUser.getEmail());
    }

    @Test
    void testCreateLocation_Success() throws Exception {
        CreateLocationRequest request = new CreateLocationRequest();
        request.setLabel("Campus");
        request.setAddress("AUB Campus");
        request.setLatitude(33.8938);
        request.setLongitude(35.5018);
        request.setIsFavorite(false);

        mockMvc.perform(post("/api/locations")
                        .header("Authorization", "Bearer " + authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.label").value("Campus"))
                .andExpect(jsonPath("$.userId").value(testUser.getId()));
    }

    @Test
    void testGetLocation_Success() throws Exception {
        mockMvc.perform(get("/api/locations/" + testLocation.getId())
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(testLocation.getId()))
                .andExpect(jsonPath("$.label").value("Home"));
    }

    @Test
    void testGetMyLocations_Success() throws Exception {
        mockMvc.perform(get("/api/locations/me")
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].userId").value(testUser.getId()));
    }

    @Test
    void testGetMyFavoriteLocations_Success() throws Exception {
        mockMvc.perform(get("/api/locations/me/favorites")
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void testCalculateDistance_Success() throws Exception {
        Location loc2 = Location.builder()
                .label("Destination")
                .latitude(33.9000)
                .longitude(35.5100)
                .user(testUser)
                .build();
        loc2 = locationRepository.save(loc2);

        mockMvc.perform(post("/api/locations/distance")
                        .header("Authorization", "Bearer " + authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"locationAId\":" + testLocation.getId() + ",\"locationBId\":" + loc2.getId() + "}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.distanceKm").exists());
    }

    @Test
    void testDeleteLocation_Success() throws Exception {
        mockMvc.perform(delete("/api/locations/" + testLocation.getId())
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().isOk());
    }
}