package me.devziyad.unipoolbackend.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingStatsResponse {
    private Long totalBookings;
    private Long confirmedBookings;
    private Long cancelledBookings;
    private Double successRate;
}

