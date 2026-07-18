package me.devziyad.unipoolbackend.vehicle;

import lombok.NonNull;
import me.devziyad.unipoolbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VehicleRepository extends JpaRepository<@NonNull Vehicle, @NonNull Long> {

    @NonNull
    List<@NonNull Vehicle> findByOwner(User owner);

    @NonNull
    List<@NonNull Vehicle> findByOwnerId(Long ownerId);

    Optional<Vehicle> findByPlateNumber(String plateNumber);
}