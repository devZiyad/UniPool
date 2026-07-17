package me.devziyad.unipoolbackend.moderation.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;
import me.devziyad.unipoolbackend.moderation.ReportType;

@Data
public class CreateReportRequest {
    @NotNull(message = "Reported user ID is required")
    private Long reportedUserId;
    
    private Long rideId;
    
    private Long bookingId;
    
    @NotNull(message = "Report type is required")
    private ReportType reportType;
    
    @NotBlank(message = "Reason is required")
    @Size(max = 2000, message = "Reason must not exceed 2000 characters")
    private String reason;
}

