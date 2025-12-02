package me.devziyad.unipoolbackend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.booking.BookingController;
import me.devziyad.unipoolbackend.booking.BookingService;
import me.devziyad.unipoolbackend.booking.dto.BookingResponse;
import me.devziyad.unipoolbackend.booking.dto.CreateBookingRequest;
import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.config.TestSecurityConfig;
import me.devziyad.unipoolbackend.user.User;
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

@WebMvcTest(controllers = BookingController.class)
@Import(TestSecurityConfig.class)
@DisplayName("BookingController Tests")
class BookingControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private BookingService bookingService;

    @MockitoBean
    private AuthService authService;

    private static final Long TEST_USER_ID = 1L;
    private static final Long TEST_BOOKING_ID = 1L;

    @Test
    @DisplayName("POST /api/bookings should return 201 with created booking")
    void create_shouldReturn201_withCreatedBooking() throws Exception {
        CreateBookingRequest request = new CreateBookingRequest();
        request.setRideId(1L);
        request.setSeats(2);

        BookingResponse response = BookingResponse.builder()
                .id(TEST_BOOKING_ID)
                .riderId(TEST_USER_ID)
                .seatsBooked(2)
                .status(BookingStatus.CONFIRMED)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(bookingService.createBooking(any(CreateBookingRequest.class), eq(TEST_USER_ID)))
                .thenReturn(response);

        mockMvc.perform(post("/api/bookings")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.riderId").value(TEST_USER_ID))
                .andExpect(jsonPath("$.seatsBooked").value(2))
                .andExpect(jsonPath("$.status").value("CONFIRMED"));
    }

    @Test
    @DisplayName("GET /api/bookings/{id} should return 200 with booking")
    void getBooking_shouldReturn200_withBooking() throws Exception {
        BookingResponse response = BookingResponse.builder()
                .id(TEST_BOOKING_ID)
                .riderId(TEST_USER_ID)
                .build();

        when(bookingService.getBookingById(TEST_BOOKING_ID)).thenReturn(response);

        mockMvc.perform(get("/api/bookings/" + TEST_BOOKING_ID))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(TEST_BOOKING_ID));
    }

    @Test
    @DisplayName("GET /api/bookings/me should return 200 with user bookings")
    void getMyBookings_shouldReturn200_withUserBookings() throws Exception {
        BookingResponse booking1 = BookingResponse.builder()
                .id(1L)
                .riderId(TEST_USER_ID)
                .build();

        BookingResponse booking2 = BookingResponse.builder()
                .id(2L)
                .riderId(TEST_USER_ID)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(bookingService.getMyBookings(TEST_USER_ID))
                .thenReturn(List.of(booking1, booking2));

        mockMvc.perform(get("/api/bookings/me"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].riderId").value(TEST_USER_ID));
    }

    @Test
    @DisplayName("POST /api/bookings/{id}/cancel should return 200")
    void cancelBooking_shouldReturn200() throws Exception {
        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);

        mockMvc.perform(post("/api/bookings/" + TEST_BOOKING_ID + "/cancel"))
                .andExpect(status().isOk());
    }
}
