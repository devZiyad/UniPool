package me.devziyad.springbootbackend.booking;

import java.util.List;

public interface BookingService {

    Booking createBooking(Long rideId, Long riderId, int seats);

    Booking getBooking(Long id);

    List<Booking> getBookingsForRider(Long riderId);

    List<Booking> getBookingsForRide(Long rideId);

    void cancelBooking(Long bookingId);
}