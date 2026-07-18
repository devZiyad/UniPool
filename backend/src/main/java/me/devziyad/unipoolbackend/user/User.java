package me.devziyad.unipoolbackend.user;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.common.Role;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_university_id", columnList = "universityId")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 300)
    private String universityId;

    @Column(nullable = false, unique = true, length = 320)
    private String email;

    @Column(nullable = false, length = 255)
    private String passwordHash;

    @Column(nullable = false, length = 300)
    private String fullName;

    @Column(unique = true, length = 30)
    private String phoneNumber;

    @Column(columnDefinition = "TEXT")
    private String universityIdImage; // Base64 encoded image or file path

    @Column(columnDefinition = "TEXT")
    private String driversLicenseImage; // Base64 encoded image or file path

    @Column(nullable = false)
    @Builder.Default
    private Boolean universityIdVerified = false; // Only admin can update

    @Column(nullable = false)
    @Builder.Default
    private Boolean verifiedDriver = false; // Only admin can update

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private Role role = Role.RIDER;

    @Column(nullable = false)
    @Builder.Default
    private Boolean enabled = true;

    @Column(nullable = false, updatable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Column(nullable = false)
    @Builder.Default
    private BigDecimal walletBalance = BigDecimal.ZERO;

    private BigDecimal avgRatingAsDriver;

    @Builder.Default
    private Integer ratingCountAsDriver = 0;

    private BigDecimal avgRatingAsRider;

    @Builder.Default
    private Integer ratingCountAsRider = 0;
}