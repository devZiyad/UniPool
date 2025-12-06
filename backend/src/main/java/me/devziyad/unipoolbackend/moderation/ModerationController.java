package me.devziyad.unipoolbackend.moderation;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.moderation.dto.CreateReportRequest;
import me.devziyad.unipoolbackend.moderation.dto.ReportResponse;
import me.devziyad.unipoolbackend.moderation.dto.ResolveReportRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/moderation")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ModerationController {

    private final ModerationService moderationService;
    private final AuthService authService;

    @PostMapping("/report")
    public ResponseEntity<@NonNull ReportResponse> createReport(@Valid @RequestBody CreateReportRequest request) {
        Long reporterId = authService.getCurrentUser().getId();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(moderationService.createReport(request, reporterId));
    }

    @GetMapping("/reports")
    public ResponseEntity<@NonNull List<@NonNull ReportResponse>> getAllReports() {
        checkAdmin();
        return ResponseEntity.ok(moderationService.getAllReports());
    }

    @GetMapping("/reports/pending")
    public ResponseEntity<@NonNull List<@NonNull ReportResponse>> getPendingReports() {
        checkAdmin();
        return ResponseEntity.ok(moderationService.getPendingReports());
    }

    @GetMapping("/reports/{id}")
    public ResponseEntity<@NonNull ReportResponse> getReport(@PathVariable Long id) {
        checkAdmin();
        return ResponseEntity.ok(moderationService.getReportById(id));
    }

    @PutMapping("/reports/{id}/resolve")
    public ResponseEntity<@NonNull ReportResponse> resolveReport(
            @PathVariable Long id,
            @Valid @RequestBody ResolveReportRequest request) {
        checkAdmin();
        Long adminId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(moderationService.resolveReport(id, request, adminId));
    }

    @PostMapping("/users/{id}/ban")
    public ResponseEntity<Void> banUser(@PathVariable Long id, @RequestBody BanRequest request, HttpServletRequest httpRequest) {
        checkAdmin();
        Long adminId = authService.getCurrentUser().getId();
        moderationService.banUser(id, request.getReason(), adminId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/users/{id}/suspend")
    public ResponseEntity<Void> suspendUser(@PathVariable Long id, @RequestBody SuspendRequest request, HttpServletRequest httpRequest) {
        checkAdmin();
        Long adminId = authService.getCurrentUser().getId();
        moderationService.suspendUser(id, request.getDays(), request.getReason(), adminId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/users/{id}/unban")
    public ResponseEntity<Void> unbanUser(@PathVariable Long id, HttpServletRequest httpRequest) {
        checkAdmin();
        Long adminId = authService.getCurrentUser().getId();
        moderationService.unbanUser(id, adminId);
        return ResponseEntity.ok().build();
    }

    private void checkAdmin() {
        if (authService.getCurrentUser().getRole() != Role.ADMIN) {
            throw new ForbiddenException("Admin access required");
        }
    }

    @lombok.Data
    public static class BanRequest {
        private String reason;
    }

    @lombok.Data
    public static class SuspendRequest {
        private int days;
        private String reason;
    }
}

