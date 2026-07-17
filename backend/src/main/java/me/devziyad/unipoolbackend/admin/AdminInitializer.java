package me.devziyad.unipoolbackend.admin;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
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

    @Override
    @Transactional
    public void run(String... args) {
        // Read admin credentials from environment variables
        String adminEmail = System.getProperty("ADMIN_EMAIL");
        String adminPassword = System.getProperty("ADMIN_PASSWORD");
        String adminUniversityId = System.getProperty("ADMIN_UNIVERSITY_ID");
        String adminFullName = System.getProperty("ADMIN_FULL_NAME");
        String adminPhoneNumber = System.getProperty("ADMIN_PHONE_NUMBER");

        // Validate that all required admin credentials are set
        if (adminEmail == null || adminEmail.isEmpty() || 
            adminPassword == null || adminPassword.isEmpty() ||
            adminUniversityId == null || adminUniversityId.isEmpty() ||
            adminFullName == null || adminFullName.isEmpty()) {
            log.error("================================================================");
            log.error("ERROR: Admin credentials are not properly configured!");
            log.error("================================================================");
            log.error("");
            log.error("Required environment variables are missing:");
            if (adminEmail == null || adminEmail.isEmpty()) {
                log.error("  - ADMIN_EMAIL (missing)");
            }
            if (adminPassword == null || adminPassword.isEmpty()) {
                log.error("  - ADMIN_PASSWORD (missing)");
            }
            if (adminUniversityId == null || adminUniversityId.isEmpty()) {
                log.error("  - ADMIN_UNIVERSITY_ID (missing)");
            }
            if (adminFullName == null || adminFullName.isEmpty()) {
                log.error("  - ADMIN_FULL_NAME (missing)");
            }
            log.error("");
            log.error("Please create a .env file in the project root directory.");
            log.error("Copy .env.template to .env and fill in your admin credentials.");
            log.error("");
            log.error("The application cannot start without admin credentials configured.");
            log.error("================================================================");
            throw new IllegalStateException("Admin credentials are not configured. Please create a .env file with required variables.");
        }
        // Check if admin user already exists
        if (userRepository.existsByEmail(adminEmail)) {
            log.info("Default admin account already exists with email: {}", adminEmail);
            // Ensure existing admin is verified
            userRepository.findByEmail(adminEmail).ifPresent(admin -> {
                boolean updated = false;
                if (!Boolean.TRUE.equals(admin.getUniversityIdVerified())) {
                    admin.setUniversityIdVerified(true);
                    updated = true;
                }
                if (!Boolean.TRUE.equals(admin.getVerifiedDriver())) {
                    admin.setVerifiedDriver(true);
                    updated = true;
                }
                if (updated) {
                    userRepository.save(admin);
                    log.info("Updated existing admin account verification status");
                }
            });
            return;
        }

        // Check if admin user exists with the university ID
        if (userRepository.existsByUniversityId(adminUniversityId)) {
            log.warn("A user with university ID {} already exists, but email doesn't match. Skipping admin initialization.", adminUniversityId);
            return;
        }

        // Create default admin user with verified status
        User admin = User.builder()
                .universityId(adminUniversityId)
                .email(adminEmail)
                .passwordHash(passwordEncoder.encode(adminPassword))
                .fullName(adminFullName)
                .phoneNumber(adminPhoneNumber != null && !adminPhoneNumber.isEmpty() ? adminPhoneNumber : null)
                .role(Role.ADMIN)
                .enabled(true)
                .universityIdVerified(true) // Admin is verified by default
                .verifiedDriver(true) // Admin is verified driver by default
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();

        userRepository.save(admin);
        log.info("Default admin account created successfully with email: {}", adminEmail);
        log.info("Default admin credentials - Email: {}, University ID: {}", adminEmail, adminUniversityId);
    }
}

