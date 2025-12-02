package me.devziyad.unipoolbackend.rating;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.booking.Booking;
import me.devziyad.unipoolbackend.booking.BookingRepository;
import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.exception.BusinessException;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.rating.dto.CreateRatingRequest;
import me.devziyad.unipoolbackend.rating.dto.RatingResponse;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RatingServiceImpl implements RatingService {

    private final RatingRepository ratingRepository;
    private final UserRepository userRepository;
    private final BookingRepository bookingRepository;

    private RatingResponse toResponse(Rating rating) {
        return RatingResponse.builder()
                .id(rating.getId())
                .fromUserId(rating.getFromUser().getId())
                .fromUserName(rating.getFromUser().getFullName())
                .toUserId(rating.getToUser().getId())
                .toUserName(rating.getToUser().getFullName())
                .bookingId(rating.getBooking().getId())
                .score(rating.getScore())
                .comment(rating.getComment())
                .createdAt(rating.getCreatedAt())
                .build();
    }

    @Override
    @Transactional
    public RatingResponse createRating(CreateRatingRequest request, Long fromUserId) {
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));

        if (booking.getStatus() != BookingStatus.COMPLETED) {
            throw new BusinessException("Can only rate completed bookings");
        }

        User fromUser = userRepository.findById(fromUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Check if user is a participant (rider or driver)
        boolean isRider = booking.getRider().getId().equals(fromUserId);
        boolean isDriver = booking.getRide().getDriver().getId().equals(fromUserId);

        if (!isRider && !isDriver) {
            throw new ForbiddenException("Only ride participants can rate each other");
        }

        // Determine who is being rated
        User toUser = isRider ? booking.getRide().getDriver() : booking.getRider();

        // Check for duplicate rating
        ratingRepository.findByBookingIdAndFromUserId(request.getBookingId(), fromUserId)
                .ifPresent(r -> {
                    throw new BusinessException("You have already rated this booking");
                });

        Rating rating = Rating.builder()
                .fromUser(fromUser)
                .toUser(toUser)
                .booking(booking)
                .score(request.getScore())
                .comment(request.getComment())
                .build();

        rating = ratingRepository.save(rating);

        // Update average ratings
        updateUserRatings(toUser);

        return toResponse(rating);
    }

    private void updateUserRatings(User user) {
        // Calculate driver rating
        List<Rating> driverRatings = ratingRepository.findByToUserId(user.getId()).stream()
                .filter(r -> r.getFromUser().getRole().name().contains("RIDER") || 
                            r.getFromUser().getRole().name().equals("BOTH"))
                .toList();

        if (!driverRatings.isEmpty()) {
            double avgDriver = driverRatings.stream()
                    .mapToInt(Rating::getScore)
                    .average()
                    .orElse(0.0);
            user.setAvgRatingAsDriver(BigDecimal.valueOf(avgDriver).setScale(2, RoundingMode.HALF_UP));
            user.setRatingCountAsDriver(driverRatings.size());
        }

        // Calculate rider rating
        List<Rating> riderRatings = ratingRepository.findByToUserId(user.getId()).stream()
                .filter(r -> r.getFromUser().getRole().name().contains("DRIVER") || 
                            r.getFromUser().getRole().name().equals("BOTH"))
                .toList();

        if (!riderRatings.isEmpty()) {
            double avgRider = riderRatings.stream()
                    .mapToInt(Rating::getScore)
                    .average()
                    .orElse(0.0);
            user.setAvgRatingAsRider(BigDecimal.valueOf(avgRider).setScale(2, RoundingMode.HALF_UP));
            user.setRatingCountAsRider(riderRatings.size());
        }

        userRepository.save(user);
    }

    @Override
    public RatingResponse getRatingById(Long id) {
        Rating rating = ratingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Rating not found"));
        return toResponse(rating);
    }

    @Override
    public List<RatingResponse> getRatingsForUser(Long userId) {
        return ratingRepository.findByToUserId(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<RatingResponse> getRatingsByUser(Long userId) {
        return ratingRepository.findByFromUserId(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public RatingResponse getRatingForBooking(Long bookingId, Long userId) {
        return ratingRepository.findByBookingIdAndFromUserId(bookingId, userId)
                .map(this::toResponse)
                .orElse(null);
    }
}
