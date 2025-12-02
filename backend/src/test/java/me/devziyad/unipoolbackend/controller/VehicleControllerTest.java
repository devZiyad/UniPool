package me.devziyad.unipoolbackend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.config.TestSecurityConfig;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.vehicle.VehicleController;
import me.devziyad.unipoolbackend.vehicle.VehicleService;
import me.devziyad.unipoolbackend.vehicle.dto.CreateVehicleRequest;
import me.devziyad.unipoolbackend.vehicle.dto.UpdateVehicleRequest;
import me.devziyad.unipoolbackend.vehicle.dto.VehicleResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(controllers = VehicleController.class)
@Import(TestSecurityConfig.class)
@DisplayName("VehicleController Tests")
class VehicleControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private VehicleService vehicleService;

    @MockitoBean
    private AuthService authService;

    private static final Long TEST_USER_ID = 1L;
    private static final Long TEST_VEHICLE_ID = 1L;

    @Test
    @DisplayName("POST /api/vehicles should return 201 with created vehicle")
    void create_shouldReturn201_withCreatedVehicle() throws Exception {
        CreateVehicleRequest request = new CreateVehicleRequest();
        request.setMake("Toyota");
        request.setModel("Corolla");
        request.setColor("Blue");
        request.setPlateNumber("ABC123");
        request.setSeatCount(4);

        VehicleResponse response = VehicleResponse.builder()
                .id(TEST_VEHICLE_ID)
                .make("Toyota")
                .model("Corolla")
                .ownerId(TEST_USER_ID)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(vehicleService.createVehicle(any(CreateVehicleRequest.class), eq(TEST_USER_ID)))
                .thenReturn(response);

        mockMvc.perform(post("/api/vehicles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.make").value("Toyota"))
                .andExpect(jsonPath("$.ownerId").value(TEST_USER_ID));
    }

    @Test
    @DisplayName("POST /api/vehicles should return 400 when validation fails")
    void create_shouldReturn400_whenValidationFails() throws Exception {
        CreateVehicleRequest request = new CreateVehicleRequest();
        // Missing required fields

        mockMvc.perform(post("/api/vehicles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("GET /api/vehicles/{id} should return 200 with vehicle")
    void getVehicle_shouldReturn200_withVehicle() throws Exception {
        VehicleResponse response = VehicleResponse.builder()
                .id(TEST_VEHICLE_ID)
                .make("Toyota")
                .model("Corolla")
                .build();

        when(vehicleService.getVehicleById(TEST_VEHICLE_ID)).thenReturn(response);

        mockMvc.perform(get("/api/vehicles/" + TEST_VEHICLE_ID))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(TEST_VEHICLE_ID))
                .andExpect(jsonPath("$.make").value("Toyota"));
    }

    @Test
    @DisplayName("GET /api/vehicles/me should return 200 with user vehicles")
    void getMyVehicles_shouldReturn200_withUserVehicles() throws Exception {
        VehicleResponse vehicle1 = VehicleResponse.builder()
                .id(1L)
                .make("Toyota")
                .ownerId(TEST_USER_ID)
                .build();

        VehicleResponse vehicle2 = VehicleResponse.builder()
                .id(2L)
                .make("Honda")
                .ownerId(TEST_USER_ID)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(vehicleService.getVehiclesForUser(TEST_USER_ID))
                .thenReturn(List.of(vehicle1, vehicle2));

        mockMvc.perform(get("/api/vehicles/me"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].ownerId").value(TEST_USER_ID));
    }

    @Test
    @DisplayName("PUT /api/vehicles/{id} should return 200 with updated vehicle")
    void update_shouldReturn200_withUpdatedVehicle() throws Exception {
        UpdateVehicleRequest request = new UpdateVehicleRequest();
        request.setColor("Red");

        VehicleResponse response = VehicleResponse.builder()
                .id(TEST_VEHICLE_ID)
                .color("Red")
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(vehicleService.updateVehicle(eq(TEST_VEHICLE_ID), any(UpdateVehicleRequest.class), eq(TEST_USER_ID)))
                .thenReturn(response);

        mockMvc.perform(put("/api/vehicles/" + TEST_VEHICLE_ID)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.color").value("Red"));
    }

    @Test
    @DisplayName("DELETE /api/vehicles/{id} should return 200")
    void delete_shouldReturn200() throws Exception {
        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);

        mockMvc.perform(delete("/api/vehicles/" + TEST_VEHICLE_ID))
                .andExpect(status().isOk());
    }
}
