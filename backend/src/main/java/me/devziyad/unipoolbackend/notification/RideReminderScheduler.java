package me.devziyad.unipoolbackend.notification;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.booking.Booking;
import me.devziyad.unipoolbackend.booking.BookingRepository;
import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.common.NotificationType;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;
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

        Instant now = Instant.now();
        Instant tenMinutesFromNow = now.plusSeconds(10 * 60L);

        // Find rides starting in the next 10 minutes
        List<Ride> upcomingRides = rideRepository.findAll().stream()
                .filter(ride -> ride.getStatus() == RideStatus.POSTED)
                .filter(ride -> ride.getDepartureTimeStart().isAfter(now))
                .filter(ride -> ride.getDepartureTimeStart().isBefore(tenMinutesFromNow))
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

