package me.devziyad.unipoolbackend.user;

import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserSettingsRepository extends JpaRepository<@NonNull UserSettings, @NonNull Long> {
    Optional<UserSettings> findByUserId(Long userId);
}