package me.devziyad.unipoolbackend.user;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.audit.ActionType;
import me.devziyad.unipoolbackend.audit.AuditService;
import me.devziyad.unipoolbackend.booking.BookingRepository;
import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.exception.UnauthorizedException;
import me.devziyad.unipoolbackend.ride.RideRepository;
import me.devziyad.unipoolbackend.user.dto.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final UserSettingsRepository settingsRepository;
    private final PasswordEncoder passwordEncoder;
    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;
    private final AuditService auditService;

    private HttpServletRequest getCurrentRequest() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        return attributes != null ? attributes.getRequest() : null;
    }

    private UserResponse toResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .universityId(user.getUniversityId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phoneNumber(user.getPhoneNumber())
                .universityIdImage(user.getUniversityIdImage())
                .driversLicenseImage(user.getDriversLicenseImage())
                .universityIdVerified(user.getUniversityIdVerified())
                .verifiedDriver(user.getVerifiedDriver())
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
    public UserResponse getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return toResponse(user);
    }

    @Override
    @Transactional
    public UserResponse updateUser(Long id, UpdateUserRequest request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }
        if (request.getPhoneNumber() != null) {
            user.setPhoneNumber(request.getPhoneNumber());
        }

        user = userRepository.save(user);

        // Audit log
        auditService.logAction(ActionType.PROFILE_UPDATE, id, getCurrentRequest());

        return toResponse(user);
    }

    @Override
    @Transactional
    public void changePassword(Long id, ChangePasswordRequest request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPasswordHash())) {
            throw new UnauthorizedException("Current password is incorrect");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        // Audit log
        auditService.logAction(ActionType.PASSWORD_CHANGE, id, getCurrentRequest());
    }

    @Override
    @Transactional
    public UserResponse updateRole(Long id, Role role) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        // Prevent ADMIN users from changing their role
        if (user.getRole() == Role.ADMIN) {
            throw new ForbiddenException("Admin users cannot change their role");
        }
        
        // Prevent setting role to ADMIN through this endpoint
        if (role == Role.ADMIN) {
            throw new ForbiddenException("Cannot set role to ADMIN through this endpoint");
        }
        
        user.setRole(role);
        return toResponse(userRepository.save(user));
    }

    @Override
    public UserSettingsResponse getUserSettings(Long userId) {
        UserSettings settings = settingsRepository.findByUserId(userId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                    UserSettings defaultSettings = UserSettings.builder()
                            .user(user)
                            .build();
                    return settingsRepository.save(defaultSettings);
                });

        return UserSettingsResponse.builder()
                .id(settings.getId())
                .emailNotifications(settings.getEmailNotifications())
                .smsNotifications(settings.getSmsNotifications())
                .pushNotifications(settings.getPushNotifications())
                .allowSmoking(settings.getAllowSmoking())
                .allowPets(settings.getAllowPets())
                .allowMusic(settings.getAllowMusic())
                .preferQuietRides(settings.getPreferQuietRides())
                .showPhoneNumber(settings.getShowPhoneNumber())
                .showEmail(settings.getShowEmail())
                .autoAcceptBookings(settings.getAutoAcceptBookings())
                .preferredPaymentMethod(settings.getPreferredPaymentMethod())
                .build();
    }

    @Override
    @Transactional
    public UserSettingsResponse updateUserSettings(Long userId, UpdateSettingsRequest request) {
        UserSettings settings = getUserSettingsEntity(userId);

        if (request.getEmailNotifications() != null) {
            settings.setEmailNotifications(request.getEmailNotifications());
        }
        if (request.getSmsNotifications() != null) {
            settings.setSmsNotifications(request.getSmsNotifications());
        }
        if (request.getPushNotifications() != null) {
            settings.setPushNotifications(request.getPushNotifications());
        }
        if (request.getAllowSmoking() != null) {
            settings.setAllowSmoking(request.getAllowSmoking());
        }
        if (request.getAllowPets() != null) {
            settings.setAllowPets(request.getAllowPets());
        }
        if (request.getAllowMusic() != null) {
            settings.setAllowMusic(request.getAllowMusic());
        }
        if (request.getPreferQuietRides() != null) {
            settings.setPreferQuietRides(request.getPreferQuietRides());
        }
        if (request.getShowPhoneNumber() != null) {
            settings.setShowPhoneNumber(request.getShowPhoneNumber());
        }
        if (request.getShowEmail() != null) {
            settings.setShowEmail(request.getShowEmail());
        }
        if (request.getAutoAcceptBookings() != null) {
            settings.setAutoAcceptBookings(request.getAutoAcceptBookings());
        }
        if (request.getPreferredPaymentMethod() != null) {
            settings.setPreferredPaymentMethod(request.getPreferredPaymentMethod());
        }

        settings = settingsRepository.save(settings);

        return UserSettingsResponse.builder()
                .id(settings.getId())
                .emailNotifications(settings.getEmailNotifications())
                .smsNotifications(settings.getSmsNotifications())
                .pushNotifications(settings.getPushNotifications())
                .allowSmoking(settings.getAllowSmoking())
                .allowPets(settings.getAllowPets())
                .allowMusic(settings.getAllowMusic())
                .preferQuietRides(settings.getPreferQuietRides())
                .showPhoneNumber(settings.getShowPhoneNumber())
                .showEmail(settings.getShowEmail())
                .autoAcceptBookings(settings.getAutoAcceptBookings())
                .preferredPaymentMethod(settings.getPreferredPaymentMethod())
                .build();
    }

    private UserSettings getUserSettingsEntity(Long userId) {
        return settingsRepository.findByUserId(userId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
                    return settingsRepository.save(UserSettings.builder().user(user).build());
                });
    }

    @Override
    public UserStatsResponse getUserStats(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        long ridesAsDriver = rideRepository.findByDriverId(userId).size();
        long bookingsAsRider = bookingRepository.findByRiderId(userId).size();

        return UserStatsResponse.builder()
                .totalRidesAsDriver(ridesAsDriver)
                .totalBookingsAsRider(bookingsAsRider)
                .avgRatingAsDriver(user.getAvgRatingAsDriver())
                .ratingCountAsDriver(user.getRatingCountAsDriver())
                .avgRatingAsRider(user.getAvgRatingAsRider())
                .ratingCountAsRider(user.getRatingCountAsRider())
                .build();
    }

    @Override
    public List<UserResponse> getAllUsers() {
        return userRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public UserResponse enableUser(Long id, Boolean enabled) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setEnabled(enabled);
        return toResponse(userRepository.save(user));
    }

    @Override
    @Transactional
    public UserResponse uploadUniversityIdImage(Long userId, String imageData) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setUniversityIdImage(imageData);
        return toResponse(userRepository.save(user));
    }

    @Override
    @Transactional
    public UserResponse uploadDriversLicenseImage(Long userId, String imageData) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setDriversLicenseImage(imageData);
        return toResponse(userRepository.save(user));
    }

    @Override
    @Transactional
    public UserResponse verifyUniversityId(Long userId, Boolean verified) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setUniversityIdVerified(verified);
        return toResponse(userRepository.save(user));
    }

    @Override
    @Transactional
    public UserResponse verifyDriver(Long userId, Boolean verified) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setVerifiedDriver(verified);
        return toResponse(userRepository.save(user));
    }
}