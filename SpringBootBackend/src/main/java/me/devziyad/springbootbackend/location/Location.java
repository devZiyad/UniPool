package me.devziyad.springbootbackend.location;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "locations")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Location {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String label;     // "Home", "Campus Gate", etc.

    private String address;   // optional free text

    private Double latitude;  // nullable until you hook GPS
    private Double longitude;
}