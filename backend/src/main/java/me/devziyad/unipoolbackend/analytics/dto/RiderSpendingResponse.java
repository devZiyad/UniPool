package me.devziyad.unipoolbackend.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RiderSpendingResponse {
    private Long riderId;
    private BigDecimal totalSpending;
    private Long totalBookings;
    private LocalDate periodFrom;
    private LocalDate periodTo;
}

