package me.devziyad.unipoolbackend.auth;

import jakarta.validation.Valid;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.dto.AuthResponse;
import me.devziyad.unipoolbackend.auth.dto.LoginRequest;
import me.devziyad.unipoolbackend.auth.dto.RegisterRequest;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.dto.UserResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<@NonNull AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/login")
    public ResponseEntity<@NonNull AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/me")
    public ResponseEntity<@NonNull UserResponse> getCurrentUser() {
        User user = authService.getCurrentUser();
        UserResponse response = UserResponse.builder()
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
        return ResponseEntity.ok(response);
    }
}