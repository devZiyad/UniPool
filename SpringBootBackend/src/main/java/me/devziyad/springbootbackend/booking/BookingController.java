package me.devziyad.springbootbackend.booking;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
@CrossOrigin
public class BookingController {

    private final BookingService bookingService;

    @PostMapping
    public ResponseEntity<Booking> create(@RequestBody CreateBookingRequest request) {
        Booking booking = bookingService.createBooking(
                request.getRideId(),
                request.getRiderId(),
                request.getSeats()
        );
        return ResponseEntity.ok(booking);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Booking> get(@PathVariable Long id) {
        return ResponseEntity.ok(bookingService.getBooking(id));
    }

    @GetMapping("/rider/{riderId}")
    public ResponseEntity<List<Booking>> forRider(@PathVariable Long riderId) {
        return ResponseEntity.ok(bookingService.getBookingsForRider(riderId));
    }

    @GetMapping("/ride/{rideId}")
    public ResponseEntity<List<Booking>> forRide(@PathVariable Long rideId) {
        return ResponseEntity.ok(bookingService.getBookingsForRide(rideId));
    }

    @PostMapping("/{bookingId}/cancel")
    public ResponseEntity<Void> cancel(@PathVariable Long bookingId) {
        bookingService.cancelBooking(bookingId);
        return ResponseEntity.ok().build();
    }

    @Data
    public static class CreateBookingRequest {
        private Long rideId;
        private Long riderId;
        private int seats;
    }
}