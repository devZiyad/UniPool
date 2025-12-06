package me.devziyad.unipoolbackend.audit;

import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AuditLogRepository extends JpaRepository<@NonNull AuditLog, @NonNull Long> {
    
    @NonNull
    List<@NonNull AuditLog> findByUserId(Long userId);
    
    @NonNull
    List<@NonNull AuditLog> findByActionType(ActionType actionType);
    
    @Query("SELECT a FROM AuditLog a WHERE a.timestamp >= :since ORDER BY a.timestamp DESC")
    @NonNull
    List<@NonNull AuditLog> findRecentLogs(@Param("since") LocalDateTime since);
    
    @Query("SELECT a FROM AuditLog a WHERE a.userId = :userId AND a.timestamp >= :since ORDER BY a.timestamp DESC")
    @NonNull
    List<@NonNull AuditLog> findUserLogsSince(@Param("userId") Long userId, @Param("since") LocalDateTime since);
}

