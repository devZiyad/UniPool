package me.devziyad.unipoolbackend.booking.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import me.devziyad.unipoolbackend.common.BookingStatus;

import java.math.BigDecimal;
import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingResponse {
    private Long bookingId;
    private Long rideId;
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
    private Instant pickupTimeStart;
    private Instant pickupTimeEnd;
    private Instant createdAt;
    private BookingStatus status;
    private BigDecimal costForThisRider;
    private Instant cancelledAt;
}

