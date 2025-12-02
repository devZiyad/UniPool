package me.devziyad.unipoolbackend.controller;

import me.devziyad.unipoolbackend.UniPoolBackendApplication;
import me.devziyad.unipoolbackend.common.NotificationType;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.notification.Notification;
import me.devziyad.unipoolbackend.notification.NotificationRepository;
import me.devziyad.unipoolbackend.security.JwtService;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.boot.test.context.SpringBootTest;
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
class NotificationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    private User testUser;
    private Notification testNotification;
    private String authToken;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
        notificationRepository.deleteAll();

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

        testNotification = Notification.builder()
                .user(testUser)
                .type(NotificationType.BOOKING_CONFIRMED)
                .title("Booking Confirmed")
                .body("Your booking has been confirmed")
                .read(false)
                .build();
        testNotification = notificationRepository.save(testNotification);

        authToken = jwtService.generateToken(testUser.getId(), testUser.getEmail());
    }

    @Test
    void testGetMyNotifications_Success() throws Exception {
        mockMvc.perform(get("/api/notifications/me")
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].userId").value(testUser.getId()));
    }

    @Test
    void testGetUnreadNotifications_Success() throws Exception {
        mockMvc.perform(get("/api/notifications/me/unread")
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void testGetUnreadCount_Success() throws Exception {
        mockMvc.perform(get("/api/notifications/me/unread-count")
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").exists());
    }

    @Test
    void testMarkAsRead_Success() throws Exception {
        mockMvc.perform(post("/api/notifications/" + testNotification.getId() + "/read")
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().isOk());
    }

    @Test
    void testMarkAllAsRead_Success() throws Exception {
        mockMvc.perform(post("/api/notifications/me/read-all")
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().isOk());
    }
}

