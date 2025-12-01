package me.devziyad.springbootbackend.rating;

import me.devziyad.springbootbackend.rating.Rating;
import me.devziyad.springbootbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RatingRepository extends JpaRepository<Rating, Long> {

    List<Rating> findByFromUser(User fromUser);

    List<Rating> findByToUser(User toUser);

    List<Rating> findByFromUserId(Long fromUserId);

    List<Rating> findByToUserId(Long toUserId);
}