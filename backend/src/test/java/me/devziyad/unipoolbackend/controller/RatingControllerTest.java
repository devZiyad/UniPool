package me.devziyad.unipoolbackend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.config.TestSecurityConfig;
import me.devziyad.unipoolbackend.rating.RatingController;
import me.devziyad.unipoolbackend.rating.RatingService;
import me.devziyad.unipoolbackend.rating.dto.CreateRatingRequest;
import me.devziyad.unipoolbackend.rating.dto.RatingResponse;
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

@WebMvcTest(controllers = RatingController.class)
@Import(TestSecurityConfig.class)
@DisplayName("RatingController Tests")
class RatingControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private RatingService ratingService;

    @MockitoBean
    private AuthService authService;

    private static final Long TEST_USER_ID = 1L;
    private static final Long TEST_RATING_ID = 1L;

    @Test
    @DisplayName("POST /api/ratings should return 201 with created rating")
    void createRating_shouldReturn201_withCreatedRating() throws Exception {
        CreateRatingRequest request = new CreateRatingRequest();
        request.setBookingId(1L);
        request.setScore(5);
        request.setComment("Great ride!");

        RatingResponse response = RatingResponse.builder()
                .id(TEST_RATING_ID)
                .fromUserId(TEST_USER_ID)
                .toUserId(2L)
                .score(5)
                .comment("Great ride!")
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(ratingService.createRating(any(CreateRatingRequest.class), eq(TEST_USER_ID)))
                .thenReturn(response);

        mockMvc.perform(post("/api/ratings")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.score").value(5))
                .andExpect(jsonPath("$.fromUserId").value(TEST_USER_ID));
    }

    @Test
    @DisplayName("POST /api/ratings should return 400 when score is invalid")
    void createRating_shouldReturn400_whenScoreInvalid() throws Exception {
        CreateRatingRequest request = new CreateRatingRequest();
        request.setBookingId(1L);
        request.setScore(10); // Invalid score (should be 1-5)

        mockMvc.perform(post("/api/ratings")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("GET /api/ratings/{id} should return 200 with rating")
    void getRating_shouldReturn200_withRating() throws Exception {
        RatingResponse response = RatingResponse.builder()
                .id(TEST_RATING_ID)
                .score(5)
                .build();

        when(ratingService.getRatingById(TEST_RATING_ID)).thenReturn(response);

        mockMvc.perform(get("/api/ratings/" + TEST_RATING_ID))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(TEST_RATING_ID))
                .andExpect(jsonPath("$.score").value(5));
    }

    @Test
    @DisplayName("GET /api/ratings/user/{userId} should return 200 with user ratings")
    void getRatingsForUser_shouldReturn200_withUserRatings() throws Exception {
        RatingResponse rating1 = RatingResponse.builder()
                .id(1L)
                .toUserId(2L)
                .score(5)
                .build();

        RatingResponse rating2 = RatingResponse.builder()
                .id(2L)
                .toUserId(2L)
                .score(4)
                .build();

        when(ratingService.getRatingsForUser(2L))
                .thenReturn(List.of(rating1, rating2));

        mockMvc.perform(get("/api/ratings/user/2"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].toUserId").value(2L));
    }

    @Test
    @DisplayName("GET /api/ratings/me/given should return 200 with ratings given by user")
    void getRatingsByMe_shouldReturn200_withRatingsGivenByUser() throws Exception {
        RatingResponse rating = RatingResponse.builder()
                .id(TEST_RATING_ID)
                .fromUserId(TEST_USER_ID)
                .score(5)
                .build();

        User currentUser = User.builder().id(TEST_USER_ID).build();

        when(authService.getCurrentUser()).thenReturn(currentUser);
        when(ratingService.getRatingsByUser(TEST_USER_ID))
                .thenReturn(List.of(rating));

        mockMvc.perform(get("/api/ratings/me/given"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].fromUserId").value(TEST_USER_ID));
    }
}
