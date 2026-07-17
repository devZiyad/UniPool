package me.devziyad.unipoolbackend.moderation.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;
import me.devziyad.unipoolbackend.moderation.ReportStatus;

@Data
public class ResolveReportRequest {
    @NotNull(message = "Status is required")
    private ReportStatus status;
    
    @Size(max = 2000, message = "Admin notes must not exceed 2000 characters")
    private String adminNotes;
}

