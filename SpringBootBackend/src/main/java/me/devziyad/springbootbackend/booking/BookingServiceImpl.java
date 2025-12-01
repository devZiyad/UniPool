package me.devziyad.springbootbackend.booking;

import lombok.RequiredArgsConstructor;
import me.devziyad.springbootbackend.common.BookingStatus;
import me.devziyad.springbootbackend.ride.Ride;
import me.devziyad.springbootbackend.ride.RideRepository;
import me.devziyad.springbootbackend.user.User;
import me.devziyad.springbootbackend.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BookingServiceImpl implements BookingService {

    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public Booking createBooking(Long rideId, Long riderId, int seats) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new IllegalArgumentException("Ride not found"));

        if (ride.getAvailableSeats() < seats) {
            throw new IllegalStateException("Not enough seats");
        }

        User rider = userRepository.findById(riderId)
                .orElseThrow(() -> new IllegalArgumentException("Rider not found"));

        // Update available seats
        ride.setAvailableSeats(ride.getAvailableSeats() - seats);
        rideRepository.save(ride);

        BigDecimal perSeat = ride.getBasePrice()
                .divide(BigDecimal.valueOf(ride.getTotalSeats()));
        BigDecimal costForRider = perSeat.multiply(BigDecimal.valueOf(seats));

        Booking booking = Booking.builder()
                .ride(ride)
                .rider(rider)
                .seatsBooked(seats)
                .status(BookingStatus.CONFIRMED)
                .costForThisRider(costForRider)
                .createdAt(LocalDateTime.now())
                .build();

        return bookingRepository.save(booking);
    }

    @Override
    public Booking getBooking(Long id) {
        return bookingRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
    }

    @Override
    public List<Booking> getBookingsForRider(Long riderId) {
        return bookingRepository.findByRiderId(riderId);
    }

    @Override
    public List<Booking> getBookingsForRide(Long rideId) {
        return bookingRepository.findByRideId(rideId);
    }

    @Override
    @Transactional
    public void cancelBooking(Long bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));

        if (booking.getStatus() == BookingStatus.CANCELLED) return;

        booking.setStatus(BookingStatus.CANCELLED);
        bookingRepository.save(booking);

        // Return seats to ride
        Ride ride = booking.getRide();
        ride.setAvailableSeats(ride.getAvailableSeats() + booking.getSeatsBooked());
        rideRepository.save(ride);
    }
}