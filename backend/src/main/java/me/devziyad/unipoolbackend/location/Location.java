package me.devziyad.unipoolbackend.location;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.user.User;

@Entity
@Table(name = "locations", indexes = {
    @Index(name = "idx_location_user_id", columnList = "user_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Location {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String label;

    @Column(length = 500)
    private String address;

    @Column(nullable = false)
    @jakarta.validation.constraints.DecimalMin(value = "-90.0", message = "Latitude must be between -90 and 90")
    @jakarta.validation.constraints.DecimalMax(value = "90.0", message = "Latitude must be between -90 and 90")
    private Double latitude;

    @Column(nullable = false)
    @jakarta.validation.constraints.DecimalMin(value = "-180.0", message = "Longitude must be between -180 and 180")
    @jakarta.validation.constraints.DecimalMax(value = "180.0", message = "Longitude must be between -180 and 180")
    private Double longitude;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isFavorite = false;
}