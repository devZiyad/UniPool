package me.devziyad.unipoolbackend.tracking;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.ride.Ride;

import java.time.LocalDateTime;

@Entity
@Table(name = "gps_tracking")
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
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(nullable = false)
    @Builder.Default
    private LocalDateTime lastUpdate = LocalDateTime.now();

    @Column(nullable = false)
    @Builder.Default
    private Boolean isActive = false;
}

