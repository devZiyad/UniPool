package me.devziyad.unipoolbackend.repository;

import me.devziyad.unipoolbackend.common.Role;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import me.devziyad.unipoolbackend.vehicle.Vehicle;
import me.devziyad.unipoolbackend.vehicle.VehicleRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DisplayName("VehicleRepository Tests")
class VehicleRepositoryTest {

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private UserRepository userRepository;

    @Test
    @DisplayName("save_shouldPersistVehicle_whenValidVehicle")
    void save_shouldPersistVehicle_whenValidVehicle() {
        // Arrange
        User owner = createTestUser();
        Vehicle vehicle = Vehicle.builder()
                .make("Toyota")
                .model("Corolla")
                .color("Blue")
                .plateNumber("ABC123")
                .seatCount(4)
                .owner(owner)
                .active(true)
                .build();

        // Act
        Vehicle saved = vehicleRepository.save(vehicle);

        // Assert
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getPlateNumber()).isEqualTo("ABC123");
        assertThat(vehicleRepository.count()).isEqualTo(1);
    }

    @Test
    @DisplayName("findByOwner_shouldReturnVehicles_whenOwnerHasVehicles")
    void findByOwner_shouldReturnVehicles_whenOwnerHasVehicles() {
        // Arrange
        User owner = createTestUser();
        Vehicle vehicle1 = Vehicle.builder()
                .make("Toyota")
                .model("Corolla")
                .plateNumber("ABC123")
                .seatCount(4)
                .owner(owner)
                .active(true)
                .build();
        Vehicle vehicle2 = Vehicle.builder()
                .make("Honda")
                .model("Civic")
                .plateNumber("XYZ789")
                .seatCount(5)
                .owner(owner)
                .active(true)
                .build();
        vehicleRepository.save(vehicle1);
        vehicleRepository.save(vehicle2);

        // Act
        List<Vehicle> vehicles = vehicleRepository.findByOwner(owner);

        // Assert
        assertThat(vehicles).hasSize(2);
        assertThat(vehicles).extracting(Vehicle::getPlateNumber)
                .containsExactlyInAnyOrder("ABC123", "XYZ789");
    }

    @Test
    @DisplayName("findByOwnerId_shouldReturnVehicles_whenOwnerIdExists")
    void findByOwnerId_shouldReturnVehicles_whenOwnerIdExists() {
        // Arrange
        User owner = createTestUser();
        Vehicle vehicle = Vehicle.builder()
                .make("Toyota")
                .model("Corolla")
                .plateNumber("ABC123")
                .seatCount(4)
                .owner(owner)
                .active(true)
                .build();
        vehicleRepository.save(vehicle);

        // Act
        List<Vehicle> vehicles = vehicleRepository.findByOwnerId(owner.getId());

        // Assert
        assertThat(vehicles).hasSize(1);
        assertThat(vehicles.get(0).getPlateNumber()).isEqualTo("ABC123");
    }

    @Test
    @DisplayName("findByPlateNumber_shouldReturnVehicle_whenPlateNumberExists")
    void findByPlateNumber_shouldReturnVehicle_whenPlateNumberExists() {
        // Arrange
        User owner = createTestUser();
        Vehicle vehicle = Vehicle.builder()
                .make("Toyota")
                .model("Corolla")
                .plateNumber("ABC123")
                .seatCount(4)
                .owner(owner)
                .active(true)
                .build();
        vehicleRepository.save(vehicle);

        // Act
        Optional<Vehicle> found = vehicleRepository.findByPlateNumber("ABC123");

        // Assert
        assertThat(found).isPresent();
        assertThat(found.get().getPlateNumber()).isEqualTo("ABC123");
    }

    private User createTestUser() {
        User user = User.builder()
                .universityId("S" + System.currentTimeMillis())
                .email("test" + System.currentTimeMillis() + "@example.com")
                .passwordHash("$2a$10$encoded")
                .fullName("Test User")
                .role(Role.DRIVER)
                .enabled(true)
                .walletBalance(BigDecimal.ZERO)
                .ratingCountAsDriver(0)
                .ratingCountAsRider(0)
                .build();
        return userRepository.save(user);
    }
}

