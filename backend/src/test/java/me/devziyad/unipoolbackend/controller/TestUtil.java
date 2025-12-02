package me.devziyad.unipoolbackend.controller;

import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
public class TestUtil {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public User createTestUser(String email, Role role) {
        User user = User.builder()
                .universityId("S" + System.currentTimeMillis())
                .email(email)
                .passwordHash(passwordEncoder.encode("password123"))
                .fullName("Test User")
                .phoneNumber("1234567890")
                .role(role)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        return userRepository.save(user);
    }

    public String generateToken(Long userId, String email) {
        // This would normally use JwtService, but for tests we'll create a simple mock token
        return "mock-token-" + userId + "-" + email;
    }
}

