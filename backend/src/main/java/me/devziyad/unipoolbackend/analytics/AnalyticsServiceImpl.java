package me.devziyad.unipoolbackend.analytics;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.analytics.dto.*;
import me.devziyad.unipoolbackend.booking.BookingRepository;
import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.payment.PaymentRepository;
import me.devziyad.unipoolbackend.payment.Payment;
import me.devziyad.unipoolbackend.common.PaymentStatus;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnalyticsServiceImpl implements AnalyticsService {

    private final PaymentRepository paymentRepository;
    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;

    @Override
    public DriverEarningsResponse getDriverEarnings(Long driverId, LocalDate from, LocalDate to) {
        List<Payment> payments = paymentRepository.findByDriverId(driverId).stream()
                .filter(p -> p.getStatus() == PaymentStatus.SETTLED)
                .filter(p -> {
                    LocalDate paymentDate = p.getCreatedAt().toLocalDate();
                    return (from == null || !paymentDate.isBefore(from)) &&
                           (to == null || !paymentDate.isAfter(to));
                })
                .toList();

        BigDecimal totalEarnings = payments.stream()
                .map(Payment::getDriverEarnings)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return DriverEarningsResponse.builder()
                .driverId(driverId)
                .totalEarnings(totalEarnings)
                .totalRides((long) payments.size())
                .periodFrom(from)
                .periodTo(to)
                .build();
    }

    @Override
    public RiderSpendingResponse getRiderSpending(Long riderId, LocalDate from, LocalDate to) {
        List<Payment> payments = paymentRepository.findByPayerId(riderId).stream()
                .filter(p -> p.getStatus() == PaymentStatus.SETTLED)
                .filter(p -> {
                    LocalDate paymentDate = p.getCreatedAt().toLocalDate();
                    return (from == null || !paymentDate.isBefore(from)) &&
                           (to == null || !paymentDate.isAfter(to));
                })
                .toList();

        BigDecimal totalSpending = payments.stream()
                .map(Payment::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return RiderSpendingResponse.builder()
                .riderId(riderId)
                .totalSpending(totalSpending)
                .totalBookings((long) payments.size())
                .periodFrom(from)
                .periodTo(to)
                .build();
    }

    @Override
    public RideStatsResponse getRideStats(Long userId) {
        List<Ride> rides = rideRepository.findByDriverId(userId);
        long totalRides = rides.size();
        long completedRides = rides.stream().filter(r -> r.getStatus() == RideStatus.COMPLETED).count();
        long cancelledRides = rides.stream().filter(r -> r.getStatus() == RideStatus.CANCELLED).count();

        return RideStatsResponse.builder()
                .totalRides(totalRides)
                .completedRides(completedRides)
                .cancelledRides(cancelledRides)
                .activeRides(rides.stream().filter(r -> r.getStatus() == RideStatus.POSTED || 
                                                       r.getStatus() == RideStatus.IN_PROGRESS).count())
                .build();
    }

    @Override
    public BookingStatsResponse getBookingStats() {
        long totalBookings = bookingRepository.count();
        long confirmedBookings = bookingRepository.findAll().stream()
                .filter(b -> b.getStatus() == BookingStatus.CONFIRMED)
                .count();
        long cancelledBookings = bookingRepository.findAll().stream()
                .filter(b -> b.getStatus() == BookingStatus.CANCELLED)
                .count();

        return BookingStatsResponse.builder()
                .totalBookings(totalBookings)
                .confirmedBookings(confirmedBookings)
                .cancelledBookings(cancelledBookings)
                .successRate(totalBookings > 0 ? (double) confirmedBookings / totalBookings * 100 : 0.0)
                .build();
    }

    @Override
    public PopularDestinationsResponse getPopularDestinations(Integer limit) {
        Map<Location, Long> destinationCounts = rideRepository.findAll().stream()
                .filter(r -> r.getStatus() == RideStatus.COMPLETED)
                .collect(Collectors.groupingBy(Ride::getDestinationLocation, Collectors.counting()));

        List<PopularDestination> popular = destinationCounts.entrySet().stream()
                .sorted(Map.Entry.<Location, Long>comparingByValue().reversed())
                .limit(limit != null ? limit : 10)
                .map(e -> PopularDestination.builder()
                        .locationId(e.getKey().getId())
                        .locationLabel(e.getKey().getLabel())
                        .rideCount(e.getValue())
                        .build())
                .collect(Collectors.toList());

        return PopularDestinationsResponse.builder()
                .destinations(popular)
                .build();
    }

    @Override
    public PeakTimesResponse getPeakTimes() {
        Map<Integer, Long> hourCounts = rideRepository.findAll().stream()
                .map(r -> r.getDepartureTime().getHour())
                .collect(Collectors.groupingBy(h -> h, Collectors.counting()));

        List<PeakTime> peakTimes = hourCounts.entrySet().stream()
                .sorted(Map.Entry.<Integer, Long>comparingByValue().reversed())
                .limit(5)
                .map(e -> PeakTime.builder()
                        .hour(e.getKey())
                        .rideCount(e.getValue())
                        .build())
                .collect(Collectors.toList());

        return PeakTimesResponse.builder()
                .peakTimes(peakTimes)
                .build();
    }

    @Override
    public DashboardStatsResponse getDashboardStats() {
        long totalUsers = rideRepository.findAll().stream()
                .map(r -> r.getDriver().getId())
                .distinct()
                .count();

        long totalRides = rideRepository.count();
        long activeRides = rideRepository.findAll().stream()
                .filter(r -> r.getStatus() == RideStatus.POSTED || r.getStatus() == RideStatus.IN_PROGRESS)
                .count();

        BigDecimal totalRevenue = paymentRepository.findAll().stream()
                .filter(p -> p.getStatus() == PaymentStatus.SETTLED)
                .map(Payment::getPlatformFee)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return DashboardStatsResponse.builder()
                .totalUsers(totalUsers)
                .totalRides(totalRides)
                .activeRides(activeRides)
                .totalRevenue(totalRevenue)
                .build();
    }
}

