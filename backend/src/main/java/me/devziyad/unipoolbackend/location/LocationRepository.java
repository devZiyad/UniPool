package me.devziyad.unipoolbackend.location;

import me.devziyad.unipoolbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LocationRepository extends JpaRepository<Location, Long> {
    List<Location> findByUserId(Long userId);
    List<Location> findByUserAndIsFavoriteTrue(User user);
}