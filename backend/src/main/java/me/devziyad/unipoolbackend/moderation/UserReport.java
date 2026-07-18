package me.devziyad.unipoolbackend.moderation;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.booking.Booking;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.user.User;

import java.time.Instant;

@Entity
@Table(name = "user_reports", indexes = {
    @Index(name = "idx_report_reporter_id", columnList = "reporter_id"),
    @Index(name = "idx_report_reported_user_id", columnList = "reported_user_id"),
    @Index(name = "idx_report_status", columnList = "status")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "reporter_id")
    private User reporter;

    @ManyToOne(optional = false)
    @JoinColumn(name = "reported_user_id")
    private User reportedUser;

    @ManyToOne
    @JoinColumn(name = "ride_id")
    private Ride ride;

    @ManyToOne
    @JoinColumn(name = "booking_id")
    private Booking booking;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private ReportType reportType = ReportType.USER;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private ReportStatus status = ReportStatus.PENDING;

    @Column(nullable = false, length = 2000)
    private String reason;

    @Column(columnDefinition = "TEXT")
    private String adminNotes;

    @ManyToOne
    @JoinColumn(name = "resolved_by_id")
    private User resolvedBy;

    @Column(nullable = false, updatable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column
    private Instant resolvedAt;
}

