package me.devziyad.unipoolbackend.moderation;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.audit.ActionType;
import me.devziyad.unipoolbackend.audit.AuditService;
import me.devziyad.unipoolbackend.booking.Booking;
import me.devziyad.unipoolbackend.booking.BookingRepository;
import me.devziyad.unipoolbackend.exception.BusinessException;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.moderation.dto.CreateReportRequest;
import me.devziyad.unipoolbackend.moderation.dto.ReportResponse;
import me.devziyad.unipoolbackend.moderation.dto.ResolveReportRequest;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import me.devziyad.unipoolbackend.util.ContentFilter;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ModerationServiceImpl implements ModerationService {

    private final UserReportRepository reportRepository;
    private final UserRepository userRepository;
    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;
    private final ContentFilter contentFilter;
    private final AuditService auditService;

    private HttpServletRequest getCurrentRequest() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        return attributes != null ? attributes.getRequest() : null;
    }

    @Override
    @Transactional
    public ReportResponse createReport(CreateReportRequest request, Long reporterId) {
        User reporter = userRepository.findById(reporterId)
                .orElseThrow(() -> new ResourceNotFoundException("Reporter not found"));

        User reportedUser = userRepository.findById(request.getReportedUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Reported user not found"));

        if (reporterId.equals(request.getReportedUserId())) {
            throw new BusinessException("Cannot report yourself");
        }

        // Sanitize reason
        String sanitizedReason = contentFilter.sanitize(request.getReason());
        if (contentFilter.containsProfanity(sanitizedReason)) {
            throw new BusinessException("Report reason contains inappropriate content");
        }

        Ride ride = null;
        if (request.getRideId() != null) {
            ride = rideRepository.findById(request.getRideId())
                    .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));
        }

        Booking booking = null;
        if (request.getBookingId() != null) {
            booking = bookingRepository.findById(request.getBookingId())
                    .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));
        }

        UserReport report = UserReport.builder()
                .reporter(reporter)
                .reportedUser(reportedUser)
                .ride(ride)
                .booking(booking)
                .reportType(request.getReportType())
                .status(ReportStatus.PENDING)
                .reason(sanitizedReason)
                .build();

        report = reportRepository.save(report);

        // Audit log
        java.util.Map<String, Object> metadata = new java.util.HashMap<>();
        metadata.put("reportId", report.getId());
        metadata.put("reportedUserId", report.getReportedUser().getId());
        metadata.put("reportType", report.getReportType().name());
        auditService.logAction(ActionType.USER_REPORT, reporterId, metadata, getCurrentRequest());

        return toResponse(report);
    }

    @Override
    public List<ReportResponse> getAllReports() {
        return reportRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<ReportResponse> getPendingReports() {
        return reportRepository.findByStatus(ReportStatus.PENDING).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public ReportResponse getReportById(Long id) {
        UserReport report = reportRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Report not found"));
        return toResponse(report);
    }

    @Override
    @Transactional
    public ReportResponse resolveReport(Long id, ResolveReportRequest request, Long adminId) {
        UserReport report = reportRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Report not found"));

        User admin = userRepository.findById(adminId)
                .orElseThrow(() -> new ResourceNotFoundException("Admin not found"));

        report.setStatus(request.getStatus());
        report.setResolvedBy(admin);
        report.setResolvedAt(LocalDateTime.now());
        if (request.getAdminNotes() != null) {
            report.setAdminNotes(contentFilter.sanitize(request.getAdminNotes()));
        }

        report = reportRepository.save(report);

        // Audit log
        java.util.Map<String, Object> metadata = new java.util.HashMap<>();
        metadata.put("reportId", report.getId());
        metadata.put("reportedUserId", report.getReportedUser().getId());
        metadata.put("status", request.getStatus().name());
        auditService.logAction(ActionType.REPORT_RESOLVE, adminId, metadata, getCurrentRequest());

        return toResponse(report);
    }

    @Override
    @Transactional
    public void banUser(Long userId, String reason, Long adminId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setEnabled(false);
        userRepository.save(user);
        
        // Audit log
        java.util.Map<String, Object> metadata = new java.util.HashMap<>();
        metadata.put("targetUserId", userId);
        metadata.put("reason", reason);
        auditService.logAction(ActionType.USER_BAN, adminId, metadata, getCurrentRequest());
    }

    @Override
    @Transactional
    public void suspendUser(Long userId, int days, String reason, Long adminId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setEnabled(false);
        userRepository.save(user);
        
        // Audit log
        java.util.Map<String, Object> metadata = new java.util.HashMap<>();
        metadata.put("targetUserId", userId);
        metadata.put("days", days);
        metadata.put("reason", reason);
        auditService.logAction(ActionType.USER_SUSPEND, adminId, metadata, getCurrentRequest());
    }

    @Override
    @Transactional
    public void unbanUser(Long userId, Long adminId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setEnabled(true);
        userRepository.save(user);
        
        // Audit log
        java.util.Map<String, Object> metadata = new java.util.HashMap<>();
        metadata.put("targetUserId", userId);
        auditService.logAction(ActionType.USER_UNBAN, adminId, metadata, getCurrentRequest());
    }

    private ReportResponse toResponse(UserReport report) {
        return ReportResponse.builder()
                .id(report.getId())
                .reporterId(report.getReporter().getId())
                .reporterName(report.getReporter().getFullName())
                .reportedUserId(report.getReportedUser().getId())
                .reportedUserName(report.getReportedUser().getFullName())
                .rideId(report.getRide() != null ? report.getRide().getId() : null)
                .bookingId(report.getBooking() != null ? report.getBooking().getId() : null)
                .reportType(report.getReportType())
                .status(report.getStatus())
                .reason(report.getReason())
                .adminNotes(report.getAdminNotes())
                .resolvedById(report.getResolvedBy() != null ? report.getResolvedBy().getId() : null)
                .resolvedByName(report.getResolvedBy() != null ? report.getResolvedBy().getFullName() : null)
                .createdAt(report.getCreatedAt())
                .resolvedAt(report.getResolvedAt())
                .build();
    }
}

