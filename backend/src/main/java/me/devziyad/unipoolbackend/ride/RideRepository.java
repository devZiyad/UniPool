package me.devziyad.unipoolbackend.ride;

import lombok.NonNull;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface RideRepository extends JpaRepository<@NonNull Ride, @NonNull Long> {

    @NonNull
    List<@NonNull Ride> findByDepartureTimeBetween(LocalDateTime from, LocalDateTime to);

    @NonNull
    List<@NonNull Ride> findByDriver(User driver);

    @NonNull
    List<@NonNull Ride> findByDriverId(Long driverId);

    @NonNull
    List<@NonNull Ride> findByStatus(RideStatus status);

    @NonNull
    List<@NonNull Ride> findByPickupLocation(Location location);

    @NonNull
    List<@NonNull Ride> findByDestinationLocation(Location location);

    @NonNull
    List<@NonNull Ride> findByDepartureTimeAfter(LocalDateTime time);

    @Query("SELECT r FROM Ride r WHERE r.driver.id = :driverId AND r.status = :status")
    @NonNull
    List<@NonNull Ride> findByDriverIdAndStatus(@Param("driverId") Long driverId, @Param("status") RideStatus status);

    @Query("SELECT r FROM Ride r WHERE r.availableSeats >= :minSeats AND r.departureTime >= :fromTime AND r.status = 'POSTED'")
    @NonNull
    List<@NonNull Ride> findAvailableRides(@Param("minSeats") Integer minSeats, @Param("fromTime") LocalDateTime fromTime);
}