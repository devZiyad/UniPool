package me.devziyad.unipoolbackend.moderation;

import me.devziyad.unipoolbackend.moderation.dto.CreateReportRequest;
import me.devziyad.unipoolbackend.moderation.dto.ReportResponse;
import me.devziyad.unipoolbackend.moderation.dto.ResolveReportRequest;

import java.util.List;

public interface ModerationService {
    ReportResponse createReport(CreateReportRequest request, Long reporterId);
    List<ReportResponse> getAllReports();
    List<ReportResponse> getPendingReports();
    ReportResponse getReportById(Long id);
    ReportResponse resolveReport(Long id, ResolveReportRequest request, Long adminId);
    void banUser(Long userId, String reason, Long adminId);
    void suspendUser(Long userId, int days, String reason, Long adminId);
    void unbanUser(Long userId, Long adminId);
}

