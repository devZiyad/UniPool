package me.devziyad.springbootbackend.rating;

import lombok.RequiredArgsConstructor;
import me.devziyad.springbootbackend.booking.Booking;
import me.devziyad.springbootbackend.booking.BookingRepository;
import me.devziyad.springbootbackend.user.User;
import me.devziyad.springbootbackend.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RatingServiceImpl implements RatingService {

    private final RatingRepository ratingRepository;
    private final UserRepository userRepository;
    private final BookingRepository bookingRepository;

    @Override
    @Transactional
    public Rating createRating(Long fromUserId, Long toUserId, Long bookingId, int score, String comment) {
        if (score < 1 || score > 5) {
            throw new IllegalArgumentException("Score must be 1–5");
        }

        User fromUser = userRepository.findById(fromUserId)
                .orElseThrow(() -> new IllegalArgumentException("From user not found"));

        User toUser = userRepository.findById(toUserId)
                .orElseThrow(() -> new IllegalArgumentException("To user not found"));

        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));

        Rating rating = Rating.builder()
                .fromUser(fromUser)
                .toUser(toUser)
                .booking(booking)
                .score(score)
                .comment(comment)
                .build();

        Rating saved = ratingRepository.save(rating);

        // Update avg rating for toUser (very simple)
        List<Rating> ratings = ratingRepository.findByToUserId(toUserId);
        double avg = ratings.stream().mapToInt(Rating::getScore).average().orElse(0.0);

        // just update one field; you can separate driver/rider logic if you want
        toUser.setAvgRatingAsDriver(BigDecimal.valueOf(avg));
        toUser.setRatingCountAsDriver(ratings.size());
        userRepository.save(toUser);

        return saved;
    }

    @Override
    public List<Rating> getRatingsForUser(Long userId) {
        return ratingRepository.findByToUserId(userId);
    }
}