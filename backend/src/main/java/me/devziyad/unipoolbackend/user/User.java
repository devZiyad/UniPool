package me.devziyad.unipoolbackend.user;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.common.Role;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String universityId;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String passwordHash;

    @Column(nullable = false)
    private String fullName;

    @Column
    private String phoneNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private Role role = Role.RIDER;

    @Column(nullable = false)
    @Builder.Default
    private Boolean enabled = true;

    @Column(nullable = false, updatable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

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