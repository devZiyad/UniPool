package me.devziyad.unipoolbackend.user;

import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.user.dto.*;

import java.util.List;

public interface UserService {
    UserResponse getUserById(Long id);
    UserResponse updateUser(Long id, UpdateUserRequest request);
    void changePassword(Long id, ChangePasswordRequest request);
    UserResponse updateRole(Long id, Role role);
    UserSettingsResponse getUserSettings(Long userId);
    UserSettingsResponse updateUserSettings(Long userId, UpdateSettingsRequest request);
    UserStatsResponse getUserStats(Long userId);
    List<UserResponse> getAllUsers();
    UserResponse enableUser(Long id, Boolean enabled);
    UserResponse uploadUniversityIdImage(Long userId, String imageData);
    UserResponse uploadDriversLicenseImage(Long userId, String imageData);
    UserResponse verifyUniversityId(Long userId, Boolean verified);
    UserResponse verifyDriver(Long userId, Boolean verified);
}