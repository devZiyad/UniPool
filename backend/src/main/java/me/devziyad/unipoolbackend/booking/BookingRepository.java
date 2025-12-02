package me.devziyad.unipoolbackend.booking;

import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.ride.Ride;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface BookingRepository extends JpaRepository<Booking, Long> {

    List<Booking> findByRider(User rider);

    List<Booking> findByRide(Ride ride);

    List<Booking> findByRiderId(Long riderId);

    List<Booking> findByRideId(Long rideId);

    List<Booking> findByRiderIdAndStatus(Long riderId, BookingStatus status);

    Optional<Booking> findByRideIdAndRiderId(Long rideId, Long riderId);

    @Query("SELECT COUNT(b) FROM Booking b WHERE b.ride.id = :rideId AND b.status != 'CANCELLED'")
    Integer countActiveBookingsByRideId(@Param("rideId") Long rideId);
}