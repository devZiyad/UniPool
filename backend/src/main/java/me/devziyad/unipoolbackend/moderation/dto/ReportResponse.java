package me.devziyad.unipoolbackend.moderation.dto;

import lombok.Builder;
import lombok.Data;
import me.devziyad.unipoolbackend.moderation.ReportStatus;
import me.devziyad.unipoolbackend.moderation.ReportType;

import java.time.LocalDateTime;

@Data
@Builder
public class ReportResponse {
    private Long id;
    private Long reporterId;
    private String reporterName;
    private Long reportedUserId;
    private String reportedUserName;
    private Long rideId;
    private Long bookingId;
    private ReportType reportType;
    private ReportStatus status;
    private String reason;
    private String adminNotes;
    private Long resolvedById;
    private String resolvedByName;
    private LocalDateTime createdAt;
    private LocalDateTime resolvedAt;
}

