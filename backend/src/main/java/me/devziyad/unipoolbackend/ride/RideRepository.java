package me.devziyad.unipoolbackend.ride;

import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface RideRepository extends JpaRepository<Ride, Long> {

    List<Ride> findByDepartureTimeBetween(LocalDateTime from, LocalDateTime to);

    List<Ride> findByDriver(User driver);

    List<Ride> findByDriverId(Long driverId);

    List<Ride> findByStatus(RideStatus status);

    List<Ride> findByPickupLocation(Location location);

    List<Ride> findByDestinationLocation(Location location);

    List<Ride> findByDepartureTimeAfter(LocalDateTime time);

    @Query("SELECT r FROM Ride r WHERE r.driver.id = :driverId AND r.status = :status")
    List<Ride> findByDriverIdAndStatus(@Param("driverId") Long driverId, @Param("status") RideStatus status);

    @Query("SELECT r FROM Ride r WHERE r.availableSeats >= :minSeats AND r.departureTime >= :fromTime AND r.status = 'POSTED'")
    List<Ride> findAvailableRides(@Param("minSeats") Integer minSeats, @Param("fromTime") LocalDateTime fromTime);
}