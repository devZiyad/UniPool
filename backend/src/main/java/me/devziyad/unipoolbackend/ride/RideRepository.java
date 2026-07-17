package me.devziyad.unipoolbackend.ride;

import jakarta.persistence.LockModeType;
import lombok.NonNull;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.user.User;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Repository
public interface RideRepository extends JpaRepository<@NonNull Ride, @NonNull Long> {
    
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT r FROM Ride r WHERE r.id = :id")
    Optional<Ride> findByIdWithLock(@Param("id") Long id);

    @Query("SELECT r FROM Ride r WHERE r.departureTimeStart >= :from AND r.departureTimeStart <= :to")
    @NonNull
    List<@NonNull Ride> findByDepartureTimeBetween(@Param("from") Instant from, @Param("to") Instant to);

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

    @Query("SELECT r FROM Ride r WHERE r.departureTimeStart > :time")
    @NonNull
    List<@NonNull Ride> findByDepartureTimeAfter(@Param("time") Instant time);

    @Query("SELECT r FROM Ride r WHERE r.driver.id = :driverId AND r.status = :status")
    @NonNull
    List<@NonNull Ride> findByDriverIdAndStatus(@Param("driverId") Long driverId, @Param("status") RideStatus status);

    @Query("SELECT r FROM Ride r WHERE r.availableSeats >= :minSeats AND r.status = 'POSTED'")
    @NonNull
    List<@NonNull Ride> findAvailableRides(@Param("minSeats") Integer minSeats);

    @Query("SELECT r FROM Ride r WHERE r.driver.id = :driverId AND r.status != 'CANCELLED' AND r.status != 'COMPLETED'")
    @NonNull
    List<@NonNull Ride> findActiveRidesByDriver(@Param("driverId") Long driverId);

    @EntityGraph(attributePaths = {"bookings", "bookings.rider", "bookings.pickupLocation", "bookings.dropoffLocation"})
    @Override
    @NonNull
    Optional<@NonNull Ride> findById(@NonNull Long id);

    @EntityGraph(attributePaths = {"bookings", "bookings.rider", "bookings.pickupLocation", "bookings.dropoffLocation"})
    @Query("SELECT r FROM Ride r WHERE r.driver.id = :driverId")
    @NonNull
    List<@NonNull Ride> findByDriverIdWithBookings(@Param("driverId") Long driverId);

    @EntityGraph(attributePaths = {"bookings", "bookings.rider", "bookings.pickupLocation", "bookings.dropoffLocation"})
    @Query("SELECT r FROM Ride r WHERE r.availableSeats >= :minSeats AND r.status = 'POSTED'")
    @NonNull
    List<@NonNull Ride> findAvailableRidesWithBookings(@Param("minSeats") Integer minSeats);
}