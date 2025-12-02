package me.devziyad.unipoolbackend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import me.devziyad.unipoolbackend.UniPoolBackendApplication;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.security.JwtService;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import me.devziyad.unipoolbackend.vehicle.Vehicle;
import me.devziyad.unipoolbackend.vehicle.VehicleRepository;
import me.devziyad.unipoolbackend.vehicle.dto.CreateVehicleRequest;
import me.devziyad.unipoolbackend.vehicle.dto.UpdateVehicleRequest;
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
class VehicleControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    private User driverUser;
    private User otherUser;
    private Vehicle testVehicle;
    private String driverToken;
    private String otherToken;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
        vehicleRepository.deleteAll();

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

        otherUser = User.builder()
                .universityId("O123456")
                .email("other@example.com")
                .passwordHash(passwordEncoder.encode("password123"))
                .fullName("Other User")
                .role(Role.RIDER)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        otherUser = userRepository.save(otherUser);

        testVehicle = Vehicle.builder()
                .make("Toyota")
                .model("Corolla")
                .color("Blue")
                .plateNumber("ABC123")
                .seatCount(4)
                .owner(driverUser)
                .active(true)
                .build();
        testVehicle = vehicleRepository.save(testVehicle);

        driverToken = jwtService.generateToken(driverUser.getId(), driverUser.getEmail());
        otherToken = jwtService.generateToken(otherUser.getId(), otherUser.getEmail());
    }

    @Test
    void testCreateVehicle_Success() throws Exception {
        CreateVehicleRequest request = new CreateVehicleRequest();
        request.setMake("Honda");
        request.setModel("Civic");
        request.setColor("Red");
        request.setPlateNumber("XYZ789");
        request.setSeatCount(5);

        mockMvc.perform(post("/api/vehicles")
                        .header("Authorization", "Bearer " + driverToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.make").value("Honda"))
                .andExpect(jsonPath("$.ownerId").value(driverUser.getId()));
    }

    @Test
    void testCreateVehicle_Unauthenticated() throws Exception {
        CreateVehicleRequest request = new CreateVehicleRequest();
        request.setMake("Honda");
        request.setModel("Civic");
        request.setPlateNumber("XYZ789");
        request.setSeatCount(5);

        mockMvc.perform(post("/api/vehicles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void testGetVehicle_Success() throws Exception {
        mockMvc.perform(get("/api/vehicles/" + testVehicle.getId())
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(testVehicle.getId()))
                .andExpect(jsonPath("$.make").value("Toyota"));
    }

    @Test
    void testGetMyVehicles_Success() throws Exception {
        mockMvc.perform(get("/api/vehicles/me")
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].ownerId").value(driverUser.getId()));
    }

    @Test
    void testUpdateVehicle_Success() throws Exception {
        UpdateVehicleRequest request = new UpdateVehicleRequest();
        request.setColor("Green");

        mockMvc.perform(put("/api/vehicles/" + testVehicle.getId())
                        .header("Authorization", "Bearer " + driverToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.color").value("Green"));
    }

    @Test
    void testUpdateVehicle_Forbidden() throws Exception {
        UpdateVehicleRequest request = new UpdateVehicleRequest();
        request.setColor("Green");

        mockMvc.perform(put("/api/vehicles/" + testVehicle.getId())
                        .header("Authorization", "Bearer " + otherToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden());
    }

    @Test
    void testDeleteVehicle_Success() throws Exception {
        mockMvc.perform(delete("/api/vehicles/" + testVehicle.getId())
                        .header("Authorization", "Bearer " + driverToken))
                .andExpect(status().isOk());
    }

    @Test
    void testDeleteVehicle_Forbidden() throws Exception {
        mockMvc.perform(delete("/api/vehicles/" + testVehicle.getId())
                        .header("Authorization", "Bearer " + otherToken))
                .andExpect(status().isForbidden());
    }
}