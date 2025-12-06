package me.devziyad.unipoolbackend.security;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.user.User;

import java.time.LocalDateTime;

@Entity
@Table(name = "failed_login_attempts", indexes = {
    @Index(name = "idx_failed_login_email", columnList = "email"),
    @Index(name = "idx_failed_login_attempt_time", columnList = "attemptTime")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FailedLoginAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 320)
    private String email;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Column(nullable = false)
    @Builder.Default
    private LocalDateTime attemptTime = LocalDateTime.now();

    @Column(length = 45)
    private String ipAddress;
}

