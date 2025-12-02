package me.devziyad.unipoolbackend.booking.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import me.devziyad.unipoolbackend.common.BookingStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingResponse {
    private Long id;
    private Long rideId;
    private Long riderId;
    private String riderName;
    private Integer seatsBooked;
    private BookingStatus status;
    private BigDecimal costForThisRider;
    private LocalDateTime createdAt;
    private LocalDateTime cancelledAt;
}

