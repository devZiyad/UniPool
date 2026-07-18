package me.devziyad.unipoolbackend.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserStatsResponse {
    private Long totalRidesAsDriver;
    private Long totalBookingsAsRider;
    private BigDecimal avgRatingAsDriver;
    private Integer ratingCountAsDriver;
    private BigDecimal avgRatingAsRider;
    private Integer ratingCountAsRider;
}