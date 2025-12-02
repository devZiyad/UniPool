package me.devziyad.unipoolbackend.route;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.location.Location;
import me.devziyad.unipoolbackend.ride.Ride;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "routes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Route {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(optional = false)
    @JoinColumn(name = "ride_id", unique = true)
    private Ride ride;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "route_stops",
            joinColumns = @JoinColumn(name = "route_id"),
            inverseJoinColumns = @JoinColumn(name = "location_id")
    )
    @OrderColumn(name = "stop_order")
    @Builder.Default
    private List<Location> stops = new ArrayList<>();

    @Column(nullable = false)
    private Double totalDistanceKm;

    @Column(nullable = false)
    private Integer estimatedDurationMinutes;

    @Column(columnDefinition = "TEXT")
    private String polyline;
}

