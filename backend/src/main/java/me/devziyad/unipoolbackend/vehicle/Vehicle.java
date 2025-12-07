package me.devziyad.unipoolbackend.vehicle;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.user.User;

import java.time.Instant;

@Entity
@Table(name = "vehicles", indexes = {
    @Index(name = "idx_vehicle_plate_number", columnList = "plateNumber"),
    @Index(name = "idx_vehicle_owner_id", columnList = "owner_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String make;

    @Column(nullable = false, length = 100)
    private String model;

    @Column(length = 100)
    private String color;

    @Column(nullable = false, unique = true, length = 50)
    private String plateNumber;

    @Column(nullable = false)
    private Integer seatCount;

    @ManyToOne(optional = false)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @Column(nullable = false, updatable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();
}