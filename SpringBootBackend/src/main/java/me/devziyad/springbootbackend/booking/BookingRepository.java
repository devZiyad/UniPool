package me.devziyad.springbootbackend.booking;

import me.devziyad.springbootbackend.booking.Booking;
import me.devziyad.springbootbackend.user.User;
import me.devziyad.springbootbackend.ride.Ride;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, Long> {

    List<Booking> findByRider(User rider);

    List<Booking> findByRide(Ride ride);

    List<Booking> findByRiderId(Long riderId);

    List<Booking> findByRideId(Long rideId);
}