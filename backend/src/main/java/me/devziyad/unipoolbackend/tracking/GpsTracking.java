package me.devziyad.unipoolbackend.tracking;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.ride.Ride;

import java.time.Instant;

@Entity
@Table(name = "gps_tracking", indexes = {
    @Index(name = "idx_gps_ride_id", columnList = "ride_id"),
    @Index(name = "idx_gps_active", columnList = "isActive")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GpsTracking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(optional = false)
    @JoinColumn(name = "ride_id", unique = true)
    private Ride ride;

    @Column(nullable = false)
    @jakarta.validation.constraints.DecimalMin(value = "-90.0", message = "Latitude must be between -90 and 90")
    @jakarta.validation.constraints.DecimalMax(value = "90.0", message = "Latitude must be between -90 and 90")
    private Double latitude;

    @Column(nullable = false)
    @jakarta.validation.constraints.DecimalMin(value = "-180.0", message = "Longitude must be between -180 and 180")
    @jakarta.validation.constraints.DecimalMax(value = "180.0", message = "Longitude must be between -180 and 180")
    private Double longitude;

    @Column(nullable = false)
    @Builder.Default
    private Instant lastUpdate = Instant.now();

    @Column(nullable = false)
    @Builder.Default
    private Boolean isActive = false;
}

