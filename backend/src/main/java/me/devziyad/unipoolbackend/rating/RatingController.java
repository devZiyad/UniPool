package me.devziyad.unipoolbackend.rating;

import jakarta.validation.Valid;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.rating.dto.CreateRatingRequest;
import me.devziyad.unipoolbackend.rating.dto.RatingResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ratings")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class RatingController {

    private final RatingService ratingService;
    private final AuthService authService;

    @PostMapping
    public ResponseEntity<@NonNull RatingResponse> createRating(@Valid @RequestBody CreateRatingRequest request) {
        Long fromUserId = authService.getCurrentUser().getId();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ratingService.createRating(request, fromUserId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<@NonNull RatingResponse> getRating(@PathVariable Long id) {
        return ResponseEntity.ok(ratingService.getRatingById(id));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<@NonNull List<@NonNull RatingResponse>> getRatingsForUser(@PathVariable Long userId) {
        return ResponseEntity.ok(ratingService.getRatingsForUser(userId));
    }

    @GetMapping("/me/given")
    public ResponseEntity<@NonNull List<@NonNull RatingResponse>> getRatingsByMe() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(ratingService.getRatingsByUser(userId));
    }

    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<@NonNull RatingResponse> getRatingForBooking(@PathVariable Long bookingId) {
        Long userId = authService.getCurrentUser().getId();
        RatingResponse rating = ratingService.getRatingForBooking(bookingId, userId);
        return rating != null ? ResponseEntity.ok(rating) : ResponseEntity.notFound().build();
    }
}