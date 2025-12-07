package me.devziyad.unipoolbackend.security;

import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
public interface FailedLoginAttemptRepository extends JpaRepository<@NonNull FailedLoginAttempt, @NonNull Long> {
    
    @Query("SELECT COUNT(f) FROM FailedLoginAttempt f WHERE f.email = :email AND f.attemptTime > :since")
    Long countFailedAttemptsSince(@Param("email") String email, @Param("since") Instant since);
    
    @Query("SELECT f FROM FailedLoginAttempt f WHERE f.email = :email AND f.attemptTime > :since ORDER BY f.attemptTime DESC")
    @NonNull
    List<@NonNull FailedLoginAttempt> findRecentFailedAttempts(@Param("email") String email, @Param("since") Instant since);
    
    @Modifying
    @Query("DELETE FROM FailedLoginAttempt f WHERE f.attemptTime < :before")
    void deleteOldAttempts(@Param("before") Instant before);
}

