package me.devziyad.springbootbackend.notification;

import lombok.RequiredArgsConstructor;
import me.devziyad.springbootbackend.booking.Booking;
import me.devziyad.springbootbackend.booking.BookingRepository;
import me.devziyad.springbootbackend.common.BookingStatus;
import me.devziyad.springbootbackend.common.NotificationType;
import me.devziyad.springbootbackend.common.RideStatus;
import me.devziyad.springbootbackend.ride.Ride;
import me.devziyad.springbootbackend.ride.RideRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
@RequiredArgsConstructor
public class RideReminderScheduler {

    private static final Logger logger = LoggerFactory.getLogger(RideReminderScheduler.class);
    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;
    private final NotificationService notificationService;

    @Scheduled(fixedRate = 600000) // Run every 10 minutes
    public void sendRideReminders() {
        logger.info("Running ride reminder scheduler");

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime tenMinutesFromNow = now.plusMinutes(10);

        // Find rides starting in the next 10 minutes
        List<Ride> upcomingRides = rideRepository.findAll().stream()
                .filter(ride -> ride.getStatus() == RideStatus.POSTED)
                .filter(ride -> ride.getDepartureTime().isAfter(now))
                .filter(ride -> ride.getDepartureTime().isBefore(tenMinutesFromNow))
                .toList();

        for (Ride ride : upcomingRides) {
            // Notify driver
            notificationService.createNotification(
                    ride.getDriver().getId(),
                    "Ride Starting Soon",
                    String.format("Your ride to %s is starting in 10 minutes", 
                            ride.getDestinationLocation().getLabel()),
                    NotificationType.RIDE_REMINDER
            );

            // Notify all passengers
            List<Booking> bookings = bookingRepository.findByRideId(ride.getId()).stream()
                    .filter(b -> b.getStatus() == BookingStatus.CONFIRMED)
                    .toList();

            for (Booking booking : bookings) {
                notificationService.createNotification(
                        booking.getRider().getId(),
                        "Ride Starting Soon",
                        String.format("Your ride to %s is starting in 10 minutes",
                                ride.getDestinationLocation().getLabel()),
                        NotificationType.RIDE_REMINDER
                );
            }
        }

        logger.info("Processed {} upcoming rides", upcomingRides.size());
    }
}

