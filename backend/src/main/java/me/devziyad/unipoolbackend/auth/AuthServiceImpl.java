package me.devziyad.unipoolbackend.auth;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.audit.ActionType;
import me.devziyad.unipoolbackend.audit.AuditService;
import me.devziyad.unipoolbackend.auth.dto.AuthResponse;
import me.devziyad.unipoolbackend.auth.dto.LoginRequest;
import me.devziyad.unipoolbackend.auth.dto.RegisterRequest;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.exception.BusinessException;
import me.devziyad.unipoolbackend.exception.UnauthorizedException;
import me.devziyad.unipoolbackend.security.FailedLoginAttempt;
import me.devziyad.unipoolbackend.security.FailedLoginAttemptRepository;
import me.devziyad.unipoolbackend.security.JwtService;
import me.devziyad.unipoolbackend.security.TokenBlacklist;
import me.devziyad.unipoolbackend.security.TokenBlacklistRepository;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import me.devziyad.unipoolbackend.user.dto.UserResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final FailedLoginAttemptRepository failedLoginAttemptRepository;
    private final TokenBlacklistRepository tokenBlacklistRepository;
    private final AuditService auditService;

    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final int LOCKOUT_DURATION_MINUTES = 15;

    private UserResponse toUserResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .universityId(user.getUniversityId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phoneNumber(user.getPhoneNumber())
                .role(user.getRole())
                .enabled(user.getEnabled())
                .createdAt(user.getCreatedAt())
                .walletBalance(user.getWalletBalance())
                .avgRatingAsDriver(user.getAvgRatingAsDriver())
                .ratingCountAsDriver(user.getRatingCountAsDriver())
                .avgRatingAsRider(user.getAvgRatingAsRider())
                .ratingCountAsRider(user.getRatingCountAsRider())
                .build();
    }

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request, HttpServletRequest httpRequest) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BusinessException("Email already exists");
        }
        if (userRepository.existsByUniversityId(request.getUniversityId())) {
            throw new BusinessException("University ID already exists");
        }

        Role role;
        if (request.getRole() != null) {
            try {
                Role requestedRole = Role.valueOf(request.getRole().toUpperCase());
                // Only allow RIDER, DRIVER, or BOTH during registration
                if (requestedRole == Role.ADMIN) {
                    throw new BusinessException("Cannot register as ADMIN. Admin accounts must be created by existing administrators.");
                }
                role = requestedRole;
            } catch (IllegalArgumentException e) {
                role = Role.RIDER;
            }
        } else {
            role = Role.RIDER;
        }

        User user = User.builder()
                .universityId(request.getUniversityId())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .phoneNumber(request.getPhoneNumber())
                .role(role)
                .enabled(true)
                .walletBalance(java.math.BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();

        user = userRepository.save(user);

        String token = jwtService.generateToken(user.getId(), user.getEmail());

        // Audit log
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("email", user.getEmail());
        metadata.put("role", role.name());
        auditService.logAction(ActionType.REGISTER, user.getId(), metadata, httpRequest);

        return new AuthResponse(token, toUserResponse(user));
    }

    @Override
    @Transactional
    public AuthResponse login(LoginRequest request, HttpServletRequest httpRequest) {
        // Check for account lockout
        LocalDateTime lockoutThreshold = LocalDateTime.now().minusMinutes(LOCKOUT_DURATION_MINUTES);
        Long failedAttempts = failedLoginAttemptRepository.countFailedAttemptsSince(request.getEmail(), lockoutThreshold);
        
        if (failedAttempts >= MAX_FAILED_ATTEMPTS) {
            throw new UnauthorizedException("Account temporarily locked due to too many failed login attempts. Please try again later.");
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseGet(() -> {
                    // Record failed attempt even if user doesn't exist
                    recordFailedLogin(request.getEmail(), null, httpRequest);
                    throw new UnauthorizedException("Invalid email or password");
                });

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            recordFailedLogin(request.getEmail(), user, httpRequest);
            throw new UnauthorizedException("Invalid email or password");
        }

        if (!user.getEnabled()) {
            throw new UnauthorizedException("Account is disabled");
        }

        // Clear failed attempts on successful login
        LocalDateTime since = LocalDateTime.now().minusHours(24);
        failedLoginAttemptRepository.findRecentFailedAttempts(request.getEmail(), since)
                .forEach(failedLoginAttemptRepository::delete);

        String token = jwtService.generateToken(user.getId(), user.getEmail());

        // Audit log
        auditService.logAction(ActionType.LOGIN, user.getId(), httpRequest);

        return new AuthResponse(token, toUserResponse(user));
    }

    private void recordFailedLogin(String email, User user, HttpServletRequest request) {
        String ipAddress = getClientIpAddress(request);
        FailedLoginAttempt attempt = FailedLoginAttempt.builder()
                .email(email)
                .user(user)
                .attemptTime(LocalDateTime.now())
                .ipAddress(ipAddress)
                .build();
        failedLoginAttemptRepository.save(attempt);
    }

    private String getClientIpAddress(HttpServletRequest request) {
        if (request == null) return null;
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        return request.getRemoteAddr();
    }

    @Override
    @Transactional
    public void logout(String token, Long userId, HttpServletRequest request) {
        // Add token to blacklist
        if (jwtService.isTokenValid(token)) {
            try {
                LocalDateTime expiresAt = new java.util.Date(jwtService.getClaims(token).getExpiration().getTime())
                        .toInstant().atZone(java.time.ZoneId.systemDefault()).toLocalDateTime();
                
                TokenBlacklist blacklistEntry = TokenBlacklist.builder()
                        .token(token)
                        .user(userRepository.findById(userId).orElse(null))
                        .expiresAt(expiresAt)
                        .blacklistedAt(LocalDateTime.now())
                        .build();
                tokenBlacklistRepository.save(blacklistEntry);
            } catch (Exception e) {
                // Token might be invalid, ignore
            }
        }

        // Audit log
        auditService.logAction(ActionType.LOGOUT, userId, request);
    }

    @Override
    public User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof User)) {
            throw new UnauthorizedException("User not authenticated");
        }
        return (User) authentication.getPrincipal();
    }
}