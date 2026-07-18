package me.devziyad.unipoolbackend.moderation;

import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserReportRepository extends JpaRepository<@NonNull UserReport, @NonNull Long> {
    
    @NonNull
    List<@NonNull UserReport> findByStatus(ReportStatus status);
    
    @NonNull
    List<@NonNull UserReport> findByReportedUserId(Long reportedUserId);
    
    @NonNull
    List<@NonNull UserReport> findByReporterId(Long reporterId);
    
    @Query("SELECT r FROM UserReport r WHERE r.reportedUser.id = :userId AND r.status = 'RESOLVED'")
    @NonNull
    List<@NonNull UserReport> findResolvedReportsByUserId(@Param("userId") Long userId);
}

