package me.devziyad.unipoolbackend.user;

import jakarta.validation.Valid;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.user.dto.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;
    private final AuthService authService;

    @GetMapping("/me")
    public ResponseEntity<@NonNull UserResponse> getCurrentUser() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(userService.getUserById(userId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<@NonNull UserResponse> getUser(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getUserById(id));
    }

    @PutMapping("/me")
    public ResponseEntity<@NonNull UserResponse> updateCurrentUser(@Valid @RequestBody UpdateUserRequest request) {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(userService.updateUser(userId, request));
    }

    @PutMapping("/me/password")
    public ResponseEntity<@NonNull Void> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        Long userId = authService.getCurrentUser().getId();
        userService.changePassword(userId, request);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/me/role")
    public ResponseEntity<@NonNull UserResponse> updateRole(@Valid @RequestBody UpdateRoleRequest request) {
        Long userId = authService.getCurrentUser().getId();
        Role role;
        try {
            role = Role.valueOf(request.getRole().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new ForbiddenException("Invalid role. Must be RIDER, DRIVER, or BOTH");
        }
        return ResponseEntity.ok(userService.updateRole(userId, role));
    }

    @lombok.Data
    public static class UpdateRoleRequest {
        private String role;
    }

    @GetMapping("/me/settings")
    public ResponseEntity<@NonNull UserSettingsResponse> getSettings() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(userService.getUserSettings(userId));
    }

    @PutMapping("/me/settings")
    public ResponseEntity<@NonNull UserSettingsResponse> updateSettings(@Valid @RequestBody UpdateSettingsRequest request) {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(userService.updateUserSettings(userId, request));
    }

    @GetMapping("/me/stats")
    public ResponseEntity<@NonNull UserStatsResponse> getStats() {
        Long userId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(userService.getUserStats(userId));
    }
}