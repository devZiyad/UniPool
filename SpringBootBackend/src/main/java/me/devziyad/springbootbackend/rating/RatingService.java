package me.devziyad.springbootbackend.rating;

import java.util.List;

public interface RatingService {

    Rating createRating(Long fromUserId, Long toUserId, Long bookingId, int score, String comment);

    List<Rating> getRatingsForUser(Long userId);
}