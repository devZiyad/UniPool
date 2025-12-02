package me.devziyad.unipoolbackend.booking;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.booking.dto.BookingResponse;
import me.devziyad.unipoolbackend.booking.dto.CreateBookingRequest;
import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.exception.BusinessException;
import me.devziyad.unipoolbackend.exception.ForbiddenException;
import me.devziyad.unipoolbackend.exception.ResourceNotFoundException;
import me.devziyad.unipoolbackend.notification.NotificationService;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
import me.devziyad.unipoolbackend.user.User;
import me.devziyad.unipoolbackend.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BookingServiceImpl implements BookingService {

    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    private BookingResponse toResponse(Booking booking) {
        return BookingResponse.builder()
                .id(booking.getId())
                .rideId(booking.getRide().getId())
                .riderId(booking.getRider().getId())
                .riderName(booking.getRider().getFullName())
                .seatsBooked(booking.getSeatsBooked())
                .status(booking.getStatus())
                .costForThisRider(booking.getCostForThisRider())
                .createdAt(booking.getCreatedAt())
                .cancelledAt(booking.getCancelledAt())
                .build();
    }

    @Override
    @Transactional
    public BookingResponse createBooking(CreateBookingRequest request, Long riderId) {
        Ride ride = rideRepository.findById(request.getRideId())
                .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));

        if (ride.getDriver().getId().equals(riderId)) {
            throw new BusinessException("Driver cannot book their own ride");
        }

        if (ride.getStatus() != RideStatus.POSTED) {
            throw new BusinessException("Ride is not available for booking");
        }

        if (ride.getDepartureTime().isBefore(LocalDateTime.now())) {
            throw new BusinessException("Cannot book past rides");
        }

        if (ride.getAvailableSeats() < request.getSeats()) {
            throw new BusinessException("Not enough available seats");
        }

        // Check for duplicate booking
        if (bookingRepository.findByRideIdAndRiderId(request.getRideId(), riderId).isPresent()) {
            throw new BusinessException("You already have a booking for this ride");
        }

        User rider = userRepository.findById(riderId)
                .orElseThrow(() -> new ResourceNotFoundException("Rider not found"));

        // Calculate cost
        BigDecimal costForRider = ride.getPricePerSeat()
                .multiply(BigDecimal.valueOf(request.getSeats()))
                .setScale(2, RoundingMode.HALF_UP);

        // Update available seats
        ride.setAvailableSeats(ride.getAvailableSeats() - request.getSeats());
        rideRepository.save(ride);

        Booking booking = Booking.builder()
                .ride(ride)
                .rider(rider)
                .seatsBooked(request.getSeats())
                .status(BookingStatus.CONFIRMED)
                .costForThisRider(costForRider)
                .build();

        booking = bookingRepository.save(booking);

        // Create notification
        notificationService.createNotification(
                ride.getDriver().getId(),
                "Booking Confirmed",
                String.format("%s booked %d seat(s) on your ride", rider.getFullName(), request.getSeats()),
                me.devziyad.unipoolbackend.common.NotificationType.BOOKING_CONFIRMED
        );

        return toResponse(booking);
    }

    @Override
    public BookingResponse getBookingById(Long id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));
        return toResponse(booking);
    }

    @Override
    public List<BookingResponse> getBookingsForRider(Long riderId) {
        return bookingRepository.findByRiderId(riderId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<BookingResponse> getBookingsForRide(Long rideId, Long driverId) {
        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new ResourceNotFoundException("Ride not found"));

        if (!ride.getDriver().getId().equals(driverId)) {
            throw new ForbiddenException("You can only view bookings for your own rides");
        }

        return bookingRepository.findByRideId(rideId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void cancelBooking(Long bookingId, Long userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));

        if (!booking.getRider().getId().equals(userId) && 
            !booking.getRide().getDriver().getId().equals(userId)) {
            throw new ForbiddenException("You can only cancel your own bookings or bookings on your rides");
        }

        if (booking.getStatus() == BookingStatus.CANCELLED) {
            throw new BusinessException("Booking is already cancelled");
        }

        if (booking.getStatus() == BookingStatus.COMPLETED) {
            throw new BusinessException("Cannot cancel completed booking");
        }

        booking.setStatus(BookingStatus.CANCELLED);
        booking.setCancelledAt(LocalDateTime.now());
        bookingRepository.save(booking);

        // Return seats to ride
        Ride ride = booking.getRide();
        ride.setAvailableSeats(ride.getAvailableSeats() + booking.getSeatsBooked());
        rideRepository.save(ride);

        // Create notification
        if (booking.getRider().getId().equals(userId)) {
            notificationService.createNotification(
                    ride.getDriver().getId(),
                    "Booking Cancelled",
                    String.format("%s cancelled their booking", booking.getRider().getFullName()),
                    me.devziyad.unipoolbackend.common.NotificationType.BOOKING_CANCELLED
            );
        } else {
            notificationService.createNotification(
                    booking.getRider().getId(),
                    "Booking Cancelled",
                    "Your booking was cancelled by the driver",
                    me.devziyad.unipoolbackend.common.NotificationType.BOOKING_CANCELLED
            );
        }
    }

    @Override
    public List<BookingResponse> getMyBookings(Long riderId) {
        return getBookingsForRider(riderId);
    }
}