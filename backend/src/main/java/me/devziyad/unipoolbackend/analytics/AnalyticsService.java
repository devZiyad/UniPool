package me.devziyad.unipoolbackend.analytics;

import me.devziyad.unipoolbackend.analytics.dto.*;

import java.time.LocalDate;

public interface AnalyticsService {
    DriverEarningsResponse getDriverEarnings(Long driverId, LocalDate from, LocalDate to);
    RiderSpendingResponse getRiderSpending(Long riderId, LocalDate from, LocalDate to);
    RideStatsResponse getRideStats(Long userId);
    BookingStatsResponse getBookingStats();
    PopularDestinationsResponse getPopularDestinations(Integer limit);
    PeakTimesResponse getPeakTimes();
    DashboardStatsResponse getDashboardStats();
}

