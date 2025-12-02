package me.devziyad.unipoolbackend.rating;

import me.devziyad.unipoolbackend.rating.dto.CreateRatingRequest;
import me.devziyad.unipoolbackend.rating.dto.RatingResponse;

import java.util.List;

public interface RatingService {
    RatingResponse createRating(CreateRatingRequest request, Long fromUserId);
    RatingResponse getRatingById(Long id);
    List<RatingResponse> getRatingsForUser(Long userId);
    List<RatingResponse> getRatingsByUser(Long userId);
    RatingResponse getRatingForBooking(Long bookingId, Long userId);
}