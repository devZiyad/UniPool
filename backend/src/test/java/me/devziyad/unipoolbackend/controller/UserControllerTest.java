package me.devziyad.unipoolbackend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.config.TestSecurityConfig;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserController;
import me.devziyad.unipoolbackend.user.UserService;
import me.devziyad.unipoolbackend.user.dto.*;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;


import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(controllers = UserController.class)
@Import(TestSecurityConfig.class)
@DisplayName("UserController Tests")
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private UserService userService;

    @MockitoBean
    private AuthService authService;

    private static final Long TEST_USER_ID = 1L;

    @Test
    @DisplayName("GET /api/users/me should return 200 with current user")
    void getCurrentUser_shouldReturn200_withCurrentUser() throws Exception {
        UserResponse userResponse = UserResponse.builder()
                .id(TEST_USER_ID)
                .email("test@example.com")
                .fullName("Test User")
                .role(Role.RIDER)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(userService.getUserById(TEST_USER_ID)).thenReturn(userResponse);

        mockMvc.perform(get("/api/users/me"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(TEST_USER_ID))
                .andExpect(jsonPath("$.email").value("test@example.com"));
    }

    @Test
    @DisplayName("GET /api/users/{id} should return 200 with user")
    void getUser_shouldReturn200_withUser() throws Exception {
        UserResponse userResponse = UserResponse.builder()
                .id(TEST_USER_ID)
                .email("test@example.com")
                .build();

        when(userService.getUserById(TEST_USER_ID)).thenReturn(userResponse);

        mockMvc.perform(get("/api/users/" + TEST_USER_ID))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(TEST_USER_ID));
    }

    @Test
    @DisplayName("PUT /api/users/me should return 200 with updated user")
    void updateCurrentUser_shouldReturn200_withUpdatedUser() throws Exception {
        UpdateUserRequest request = new UpdateUserRequest();
        request.setFullName("Updated Name");
        request.setPhoneNumber("9876543210");

        UserResponse userResponse = UserResponse.builder()
                .id(TEST_USER_ID)
                .fullName("Updated Name")
                .phoneNumber("9876543210")
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(userService.updateUser(eq(TEST_USER_ID), any(UpdateUserRequest.class)))
                .thenReturn(userResponse);

        mockMvc.perform(put("/api/users/me")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.fullName").value("Updated Name"));
    }

    @Test
    @DisplayName("PUT /api/users/me/password should return 200")
    void changePassword_shouldReturn200() throws Exception {
        ChangePasswordRequest request = new ChangePasswordRequest();
        request.setOldPassword("oldPassword");
        request.setNewPassword("newPassword");

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);

        mockMvc.perform(put("/api/users/me/password")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("GET /api/users/me/settings should return 200 with settings")
    void getSettings_shouldReturn200_withSettings() throws Exception {
        UserSettingsResponse settingsResponse = UserSettingsResponse.builder()
                .emailNotifications(true)
                .pushNotifications(false)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(userService.getUserSettings(TEST_USER_ID)).thenReturn(settingsResponse);

        mockMvc.perform(get("/api/users/me/settings"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.emailNotifications").exists());
    }

    @Test
    @DisplayName("GET /api/users/me/stats should return 200 with stats")
    void getStats_shouldReturn200_withStats() throws Exception {
        UserStatsResponse statsResponse = UserStatsResponse.builder()
                .totalRidesAsDriver(10L)
                .totalBookingsAsRider(20L)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(userService.getUserStats(TEST_USER_ID)).thenReturn(statsResponse);

        mockMvc.perform(get("/api/users/me/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalRidesAsDriver").exists());
    }
}
