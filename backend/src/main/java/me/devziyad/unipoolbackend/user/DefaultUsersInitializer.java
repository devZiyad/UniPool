package me.devziyad.unipoolbackend.user;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import me.devziyad.unipoolbackend.common.Role;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Component
@RequiredArgsConstructor
@Slf4j
@Order(1) // Run after AdminInitializer (which has default order)
public class DefaultUsersInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) {
        // Read user credentials from environment variables
        createDefaultUser(
                System.getProperty("DEFAULT_USER1_EMAIL"),
                System.getProperty("DEFAULT_USER1_PASSWORD"),
                System.getProperty("DEFAULT_USER1_UNIVERSITY_ID"),
                System.getProperty("DEFAULT_USER1_FULL_NAME"),
                System.getProperty("DEFAULT_USER1_PHONE_NUMBER"),
                1
        );

        createDefaultUser(
                System.getProperty("DEFAULT_USER2_EMAIL"),
                System.getProperty("DEFAULT_USER2_PASSWORD"),
                System.getProperty("DEFAULT_USER2_UNIVERSITY_ID"),
                System.getProperty("DEFAULT_USER2_FULL_NAME"),
                System.getProperty("DEFAULT_USER2_PHONE_NUMBER"),
                2
        );

        createDefaultUser(
                System.getProperty("DEFAULT_USER3_EMAIL"),
                System.getProperty("DEFAULT_USER3_PASSWORD"),
                System.getProperty("DEFAULT_USER3_UNIVERSITY_ID"),
                System.getProperty("DEFAULT_USER3_FULL_NAME"),
                System.getProperty("DEFAULT_USER3_PHONE_NUMBER"),
                3
        );
    }

    private void createDefaultUser(String email, String password, String universityId, 
                                   String fullName, String phoneNumber, int userNumber) {
        // Skip if credentials are not provided
        if (email == null || email.isEmpty() || 
            password == null || password.isEmpty() ||
            universityId == null || universityId.isEmpty() ||
            fullName == null || fullName.isEmpty()) {
            log.debug("Default user {} credentials not provided, skipping initialization", userNumber);
            return;
        }

        // Check if user already exists
        if (userRepository.existsByEmail(email)) {
            log.debug("Default user {} already exists with email: {}", userNumber, email);
            return;
        }

        // Check if user exists with the university ID
        if (userRepository.existsByUniversityId(universityId)) {
            log.warn("A user with university ID {} already exists, but email doesn't match. Skipping default user {} initialization.", 
                    universityId, userNumber);
            return;
        }

        // Create default user (normal user, not admin)
        User user = User.builder()
                .universityId(universityId)
                .email(email)
                .passwordHash(passwordEncoder.encode(password))
                .fullName(fullName)
                .phoneNumber(phoneNumber != null && !phoneNumber.isEmpty() ? phoneNumber : null)
                .role(Role.RIDER) // Default to RIDER role
                .enabled(true)
                .universityIdVerified(false) // Not verified by default
                .verifiedDriver(false) // Not verified driver by default
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();

        userRepository.save(user);
        log.info("Default user {} created successfully with email: {}", userNumber, email);
    }
}

