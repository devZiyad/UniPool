package me.devziyad.unipoolbackend.route.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateRouteRequest {
    @NotNull(message = "Start latitude is required")
    @DecimalMin(value = "-90.0", message = "Start latitude must be between -90 and 90")
    @DecimalMax(value = "90.0", message = "Start latitude must be between -90 and 90")
    private Double startLatitude;

    @NotNull(message = "Start longitude is required")
    @DecimalMin(value = "-180.0", message = "Start longitude must be between -180 and 180")
    @DecimalMax(value = "180.0", message = "Start longitude must be between -180 and 180")
    private Double startLongitude;

    @NotNull(message = "End latitude is required")
    @DecimalMin(value = "-90.0", message = "End latitude must be between -90 and 90")
    @DecimalMax(value = "90.0", message = "End latitude must be between -90 and 90")
    private Double endLatitude;

    @NotNull(message = "End longitude is required")
    @DecimalMin(value = "-180.0", message = "End longitude must be between -180 and 180")
    @DecimalMax(value = "180.0", message = "End longitude must be between -180 and 180")
    private Double endLongitude;
}

