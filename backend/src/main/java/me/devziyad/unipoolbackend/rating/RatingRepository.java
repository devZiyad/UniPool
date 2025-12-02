package me.devziyad.unipoolbackend.rating;

import me.devziyad.unipoolbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface RatingRepository extends JpaRepository<Rating, Long> {

    List<Rating> findByFromUser(User fromUser);

    List<Rating> findByToUser(User toUser);

    List<Rating> findByFromUserId(Long fromUserId);

    List<Rating> findByToUserId(Long toUserId);

    Optional<Rating> findByBookingIdAndFromUserId(Long bookingId, Long fromUserId);

    @Query("SELECT AVG(r.score) FROM Rating r WHERE r.toUser.id = :userId AND r.fromUser.role IN ('DRIVER', 'BOTH')")
    Double getAverageDriverRating(@Param("userId") Long userId);

    @Query("SELECT AVG(r.score) FROM Rating r WHERE r.toUser.id = :userId AND r.fromUser.role IN ('RIDER', 'BOTH')")
    Double getAverageRiderRating(@Param("userId") Long userId);
}