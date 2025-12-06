package me.devziyad.unipoolbackend.booking.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import me.devziyad.unipoolbackend.common.BookingStatus;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingResponse {
    private Long bookingId;
    private Long passengerId;
    private String passengerName;
    private Integer seatsBooked;
    private Long pickupLocationId;
    private String pickupLocationLabel;
    private Double pickupLatitude;
    private Double pickupLongitude;
    private Long dropoffLocationId;
    private String dropoffLocationLabel;
    private Double dropoffLatitude;
    private Double dropoffLongitude;
    private java.time.LocalDateTime pickupTimeStart;
    private java.time.LocalDateTime pickupTimeEnd;
    private Instant createdAt;
    private BookingStatus status;
    private BigDecimal costForThisRider;
    private LocalDateTime cancelledAt;
}

