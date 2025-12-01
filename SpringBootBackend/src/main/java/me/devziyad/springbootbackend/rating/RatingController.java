package me.devziyad.springbootbackend.rating;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ratings")
@RequiredArgsConstructor
@CrossOrigin
public class RatingController {

    private final RatingService ratingService;

    @PostMapping
    public ResponseEntity<Rating> create(@RequestBody CreateRatingRequest request) {
        Rating rating = ratingService.createRating(
                request.getFromUserId(),
                request.getToUserId(),
                request.getBookingId(),
                request.getScore(),
                request.getComment()
        );
        return ResponseEntity.ok(rating);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Rating>> forUser(@PathVariable Long userId) {
        return ResponseEntity.ok(ratingService.getRatingsForUser(userId));
    }

    @Data
    public static class CreateRatingRequest {
        private Long fromUserId;
        private Long toUserId;
        private Long bookingId;
        private int score;
        private String comment;
    }
}