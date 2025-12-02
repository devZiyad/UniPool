package me.devziyad.unipoolbackend.location;

import lombok.NonNull;
import me.devziyad.unipoolbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LocationRepository extends JpaRepository<@NonNull Location, @NonNull Long> {
    @NonNull
    List<@NonNull Location> findByUserId(Long userId);
    @NonNull
    List<@NonNull Location> findByUserAndIsFavoriteTrue(User user);
}