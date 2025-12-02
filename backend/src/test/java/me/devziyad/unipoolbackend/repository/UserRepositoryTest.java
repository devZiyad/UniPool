package me.devziyad.unipoolbackend.repository;

import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import java.math.BigDecimal;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DisplayName("UserRepository Tests")
class UserRepositoryTest {

    @Autowired
    private UserRepository userRepository;

    @Test
    @DisplayName("save_shouldPersistUser_whenValidUser")
    void save_shouldPersistUser_whenValidUser() {
        // Arrange
        User user = User.builder()
                .universityId("S123456")
                .email("test@example.com")
                .passwordHash("$2a$10$encoded")
                .fullName("Test User")
                .role(Role.RIDER)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();

        // Act
        User saved = userRepository.save(user);

        // Assert
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getEmail()).isEqualTo("test@example.com");
        assertThat(userRepository.count()).isEqualTo(1);
    }

    @Test
    @DisplayName("findByEmail_shouldReturnUser_whenUserExists")
    void findByEmail_shouldReturnUser_whenUserExists() {
        // Arrange
        User user = User.builder()
                .universityId("S123456")
                .email("test@example.com")
                .passwordHash("$2a$10$encoded")
                .fullName("Test User")
                .role(Role.RIDER)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        userRepository.save(user);

        // Act
        Optional<User> found = userRepository.findByEmail("test@example.com");

        // Assert
        assertThat(found).isPresent();
        assertThat(found.get().getEmail()).isEqualTo("test@example.com");
    }

    @Test
    @DisplayName("existsByEmail_shouldReturnTrue_whenEmailExists")
    void existsByEmail_shouldReturnTrue_whenEmailExists() {
        // Arrange
        User user = User.builder()
                .universityId("S123456")
                .email("test@example.com")
                .passwordHash("$2a$10$encoded")
                .fullName("Test User")
                .role(Role.RIDER)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        userRepository.save(user);

        // Act
        boolean exists = userRepository.existsByEmail("test@example.com");

        // Assert
        assertThat(exists).isTrue();
    }

    @Test
    @DisplayName("existsByUniversityId_shouldReturnTrue_whenUniversityIdExists")
    void existsByUniversityId_shouldReturnTrue_whenUniversityIdExists() {
        // Arrange
        User user = User.builder()
                .universityId("S123456")
                .email("test@example.com")
                .passwordHash("$2a$10$encoded")
                .fullName("Test User")
                .role(Role.RIDER)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        userRepository.save(user);

        // Act
        boolean exists = userRepository.existsByUniversityId("S123456");

        // Assert
        assertThat(exists).isTrue();
    }
}

