package me.devziyad.unipoolbackend.analytics;

import lombok.RequiredArgsConstructor;
import me.devziyad.unipoolbackend.analytics.dto.*;
import me.devziyad.unipoolbackend.booking.BookingRepository;
import me.devziyad.unipoolbackend.common.BookingStatus;
import me.devziyad.unipoolbackend.common.PaymentStatus;
import me.devziyad.unipoolbackend.common.RideStatus;
import me.devziyad.unipoolbackend.payment.Payment;
import me.devziyad.unipoolbackend.payment.PaymentRepository;
import me.devziyad.unipoolbackend.ride.Ride;
import me.devziyad.unipoolbackend.ride.RideRepository;
import me.devziyad.unipoolbackend.user.UserRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AnalyticsServiceImpl implements AnalyticsService {

    private final PaymentRepository paymentRepository;
    private final RideRepository rideRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;

    @Override
    public DriverEarningsResponse getDriverEarnings(Long driverId, LocalDate from, LocalDate to) {
        List<Payment> payments = paymentRepository.findByDriverId(driverId).stream()
                .filter(p -> p.getStatus() == PaymentStatus.SETTLED)
                .filter(p -> {
                    java.time.LocalDate paymentDate = p.getCreatedAt().atZone(java.time.ZoneId.of("UTC")).toLocalDate();
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
                    java.time.LocalDate paymentDate = p.getCreatedAt().atZone(java.time.ZoneId.of("UTC")).toLocalDate();
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
        long confirmedBookings = bookingRepository.countByStatus(BookingStatus.CONFIRMED);
        long cancelledBookings = bookingRepository.countByStatus(BookingStatus.CANCELLED);

        return BookingStatsResponse.builder()
                .totalBookings(totalBookings)
                .confirmedBookings(confirmedBookings)
                .cancelledBookings(cancelledBookings)
                .successRate(totalBookings > 0 ? (double) confirmedBookings / totalBookings * 100 : 0.0)
                .build();
    }

    @Override
    public PopularDestinationsResponse getPopularDestinations(Integer limit) {
        int pageSize = limit != null && limit > 0 ? limit : 10;
        List<Object[]> rows = rideRepository.findPopularDestinations(
                RideStatus.COMPLETED, PageRequest.of(0, pageSize));

        List<PopularDestination> popular = rows.stream()
                .map(row -> PopularDestination.builder()
                        .locationId((Long) row[0])
                        .locationLabel((String) row[1])
                        .rideCount((Long) row[2])
                        .build())
                .collect(Collectors.toList());

        return PopularDestinationsResponse.builder()
                .destinations(popular)
                .build();
    }

    @Override
    public PeakTimesResponse getPeakTimes() {
        Map<Integer, Long> hourCounts = rideRepository.findAllDepartureTimes().stream()
                .map(instant -> instant.atZone(java.time.ZoneId.of("UTC")).getHour())
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
        long totalUsers = userRepository.count();
        long totalRides = rideRepository.count();
        long activeRides = rideRepository.countByStatusIn(
                List.of(RideStatus.POSTED, RideStatus.IN_PROGRESS));
        BigDecimal totalRevenue = paymentRepository.sumPlatformFeeByStatus(PaymentStatus.SETTLED);

        return DashboardStatsResponse.builder()
                .totalUsers(totalUsers)
                .totalRides(totalRides)
                .activeRides(activeRides)
                .totalRevenue(totalRevenue != null ? totalRevenue : BigDecimal.ZERO)
                .build();
    }
}
