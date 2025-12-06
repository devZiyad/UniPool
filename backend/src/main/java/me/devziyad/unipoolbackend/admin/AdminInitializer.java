package me.devziyad.unipoolbackend.admin;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Component
@RequiredArgsConstructor
@Slf4j
public class AdminInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${admin.default.email}")
    private String adminEmail;

    @Value("${admin.default.password}")
    private String adminPassword;

    @Value("${admin.default.universityId}")
    private String adminUniversityId;

    @Value("${admin.default.fullName}")
    private String adminFullName;

    @Value("${admin.default.phoneNumber:}")
    private String adminPhoneNumber;

    @Override
    @Transactional
    public void run(String... args) {
        // Check if admin user already exists
        if (userRepository.existsByEmail(adminEmail)) {
            log.info("Default admin account already exists with email: {}", adminEmail);
            return;
        }

        // Check if admin user exists with the university ID
        if (userRepository.existsByUniversityId(adminUniversityId)) {
            log.warn("A user with university ID {} already exists, but email doesn't match. Skipping admin initialization.", adminUniversityId);
            return;
        }

        // Create default admin user
        User admin = User.builder()
                .universityId(adminUniversityId)
                .email(adminEmail)
                .passwordHash(passwordEncoder.encode(adminPassword))
                .fullName(adminFullName)
                .phoneNumber(adminPhoneNumber != null && !adminPhoneNumber.isEmpty() ? adminPhoneNumber : null)
                .role(Role.ADMIN)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();

        userRepository.save(admin);
        log.info("Default admin account created successfully with email: {}", adminEmail);
        log.info("Default admin credentials - Email: {}, University ID: {}", adminEmail, adminUniversityId);
    }
}

