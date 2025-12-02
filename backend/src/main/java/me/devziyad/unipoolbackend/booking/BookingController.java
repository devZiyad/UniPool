package me.devziyad.unipoolbackend.booking;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.auth.AuthService;
import me.devziyad.unipoolbackend.booking.dto.BookingResponse;
import me.devziyad.unipoolbackend.booking.dto.CreateBookingRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class BookingController {

    private final BookingService bookingService;
    private final AuthService authService;

    @PostMapping
    public ResponseEntity<BookingResponse> create(@Valid @RequestBody CreateBookingRequest request) {
        Long riderId = authService.getCurrentUser().getId();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(bookingService.createBooking(request, riderId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<BookingResponse> getBooking(@PathVariable Long id) {
        return ResponseEntity.ok(bookingService.getBookingById(id));
    }

    @GetMapping("/me")
    public ResponseEntity<List<BookingResponse>> getMyBookings() {
        Long riderId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(bookingService.getMyBookings(riderId));
    }

    @GetMapping("/rider/{riderId}")
    public ResponseEntity<List<BookingResponse>> getBookingsForRider(@PathVariable Long riderId) {
        return ResponseEntity.ok(bookingService.getBookingsForRider(riderId));
    }

    @GetMapping("/ride/{rideId}")
    public ResponseEntity<List<BookingResponse>> getBookingsForRide(@PathVariable Long rideId) {
        Long driverId = authService.getCurrentUser().getId();
        return ResponseEntity.ok(bookingService.getBookingsForRide(rideId, driverId));
    }

    @PostMapping("/{bookingId}/cancel")
    public ResponseEntity<Void> cancelBooking(@PathVariable Long bookingId) {
        Long userId = authService.getCurrentUser().getId();
        bookingService.cancelBooking(bookingId, userId);
        return ResponseEntity.ok().build();
    }
}