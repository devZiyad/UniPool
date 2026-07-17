package me.devziyad.unipoolbackend.booking;

import lombok.NonNull;
import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.ride.Ride;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BookingRepository extends JpaRepository<@NonNull Booking, @NonNull Long> {

    @NonNull
    List<@NonNull Booking> findByRider(User rider);

    @NonNull
    List<@NonNull Booking> findByRide(Ride ride);

    @NonNull
    List<@NonNull Booking> findByRiderId(Long riderId);

    @NonNull
    List<@NonNull Booking> findByRideId(Long rideId);

    @NonNull
    List<@NonNull Booking> findByRiderIdAndStatus(Long riderId, BookingStatus status);

    Optional<Booking> findByRideIdAndRiderId(Long rideId, Long riderId);

    @Query("SELECT COUNT(b) FROM Booking b WHERE b.ride.id = :rideId AND b.status != 'CANCELLED'")
    @NonNull
    Integer countActiveBookingsByRideId(@Param("rideId") Long rideId);
}