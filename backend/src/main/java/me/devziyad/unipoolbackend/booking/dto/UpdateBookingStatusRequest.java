package me.devziyad.unipoolbackend.booking.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import me.devziyad.unipoolbackend.common.BookingStatus;

@Data
public class UpdateBookingStatusRequest {
    @NotNull(message = "Status is required")
    private BookingStatus status;
}

