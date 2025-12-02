package me.devziyad.unipoolbackend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.config.TestSecurityConfig;
import me.devziyad.unipoolbackend.ride.RideController;
import me.devziyad.unipoolbackend.ride.RideService;
import me.devziyad.unipoolbackend.ride.dto.CreateRideRequest;
import me.devziyad.unipoolbackend.ride.dto.RideResponse;
import me.devziyad.unipoolbackend.ride.dto.SearchRidesRequest;
import me.devziyad.unipoolbackend.user.User;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(controllers = RideController.class)
@Import(TestSecurityConfig.class)
@DisplayName("RideController Tests")
class RideControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private RideService rideService;

    @MockitoBean
    private AuthService authService;

    private static final Long TEST_USER_ID = 1L;
    private static final Long TEST_RIDE_ID = 1L;

    @Test
    @DisplayName("POST /api/rides should return 201 with created ride")
    void createRide_shouldReturn201_withCreatedRide() throws Exception {
        CreateRideRequest request = new CreateRideRequest();
        request.setVehicleId(1L);
        request.setPickupLocationId(1L);
        request.setDestinationLocationId(2L);
        request.setDepartureTime(LocalDateTime.now().plusHours(2));
        request.setTotalSeats(4);

        RideResponse response = RideResponse.builder()
                .id(TEST_RIDE_ID)
                .driverId(TEST_USER_ID)
                .status(RideStatus.POSTED)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(rideService.createRide(any(CreateRideRequest.class), eq(TEST_USER_ID)))
                .thenReturn(response);

        mockMvc.perform(post("/api/rides")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.driverId").value(TEST_USER_ID))
                .andExpect(jsonPath("$.status").value("POSTED"));
    }

    @Test
    @DisplayName("GET /api/rides/{id} should return 200 with ride")
    void getRide_shouldReturn200_withRide() throws Exception {
        RideResponse response = RideResponse.builder()
                .id(TEST_RIDE_ID)
                .driverId(TEST_USER_ID)
                .build();

        when(rideService.getRideById(TEST_RIDE_ID)).thenReturn(response);

        mockMvc.perform(get("/api/rides/" + TEST_RIDE_ID))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(TEST_RIDE_ID));
    }

    @Test
    @DisplayName("POST /api/rides/search should return 200 with list of rides")
    void searchRides_shouldReturn200_withListOfRides() throws Exception {
        SearchRidesRequest request = new SearchRidesRequest();
        request.setPickupLocationId(1L);
        request.setDestinationLocationId(2L);
        request.setMinAvailableSeats(1);

        RideResponse ride1 = RideResponse.builder()
                .id(1L)
                .driverId(TEST_USER_ID)
                .build();

        RideResponse ride2 = RideResponse.builder()
                .id(2L)
                .driverId(2L)
                .build();

        when(rideService.searchRides(any(SearchRidesRequest.class)))
                .thenReturn(List.of(ride1, ride2));

        mockMvc.perform(post("/api/rides/search")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].id").exists());
    }

    @Test
    @DisplayName("GET /api/rides/me/driver should return 200 with driver rides")
    void getMyRidesAsDriver_shouldReturn200_withDriverRides() throws Exception {
        RideResponse ride = RideResponse.builder()
                .id(TEST_RIDE_ID)
                .driverId(TEST_USER_ID)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(rideService.getMyRidesAsDriver(TEST_USER_ID))
                .thenReturn(List.of(ride));

        mockMvc.perform(get("/api/rides/me/driver"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].driverId").value(TEST_USER_ID));
    }

    @Test
    @DisplayName("PATCH /api/rides/{id}/status should return 200 with updated ride")
    void updateRideStatus_shouldReturn200_withUpdatedRide() throws Exception {
        RideResponse response = RideResponse.builder()
                .id(TEST_RIDE_ID)
                .status(RideStatus.IN_PROGRESS)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(rideService.updateRideStatus(eq(TEST_RIDE_ID), eq(RideStatus.IN_PROGRESS), eq(TEST_USER_ID)))
                .thenReturn(response);

        mockMvc.perform(patch("/api/rides/" + TEST_RIDE_ID + "/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"IN_PROGRESS\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("IN_PROGRESS"));
    }

    @Test
    @DisplayName("GET /api/rides/{id}/available-seats should return 200 with seat count")
    void getAvailableSeats_shouldReturn200_withSeatCount() throws Exception {
        when(rideService.getAvailableSeats(TEST_RIDE_ID)).thenReturn(3);

        mockMvc.perform(get("/api/rides/" + TEST_RIDE_ID + "/available-seats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").value(3));
    }
}
