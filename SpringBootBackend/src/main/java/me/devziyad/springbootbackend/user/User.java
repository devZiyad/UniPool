package me.devziyad.springbootbackend.user;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.springbootbackend.common.Role;

import java.math.BigDecimal;

@Entity
@Table(name = "users")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // AUBH ID like "S123456"
    @Column(nullable = false, unique = true)
    private String universityId;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String passwordHash;  // BCrypt

    @Column(nullable = false)
    private String fullName;

    @Column
    private String phoneNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    // For rating averages
    private BigDecimal avgRatingAsDriver;
    private Integer ratingCountAsDriver;

    private BigDecimal avgRatingAsRider;
    private Integer ratingCountAsRider;
}
