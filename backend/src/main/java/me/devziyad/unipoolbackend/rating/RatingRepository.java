package me.devziyad.unipoolbackend.rating;

import lombok.NonNull;
import me.devziyad.unipoolbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RatingRepository extends JpaRepository<@NonNull Rating, @NonNull Long> {

    @NonNull
    List<@NonNull Rating> findByFromUser(User fromUser);

    @NonNull
    List<@NonNull Rating> findByToUser(User toUser);

    @NonNull
    List<@NonNull Rating> findByFromUserId(Long fromUserId);

    @NonNull
    List<@NonNull Rating> findByToUserId(Long toUserId);

    Optional<Rating> findByBookingIdAndFromUserId(Long bookingId, Long fromUserId);

    @Query("SELECT AVG(r.score) FROM Rating r WHERE r.toUser.id = :userId AND r.fromUser.role IN ('DRIVER', 'BOTH')")
    @NonNull
    Double getAverageDriverRating(@Param("userId") Long userId);

    @Query("SELECT AVG(r.score) FROM Rating r WHERE r.toUser.id = :userId AND r.fromUser.role IN ('RIDER', 'BOTH')")
    @NonNull
    Double getAverageRiderRating(@Param("userId") Long userId);
}