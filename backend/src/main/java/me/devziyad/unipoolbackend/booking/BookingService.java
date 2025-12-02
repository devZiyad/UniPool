package me.devziyad.unipoolbackend.booking;

import me.devziyad.unipoolbackend.booking.dto.BookingResponse;
import me.devziyad.unipoolbackend.booking.dto.CreateBookingRequest;

import java.util.List;

public interface BookingService {
    BookingResponse createBooking(CreateBookingRequest request, Long riderId);
    BookingResponse getBookingById(Long id);
    List<BookingResponse> getBookingsForRider(Long riderId);
    List<BookingResponse> getBookingsForRide(Long rideId, Long driverId);
    void cancelBooking(Long bookingId, Long userId);
    List<BookingResponse> getMyBookings(Long riderId);
}