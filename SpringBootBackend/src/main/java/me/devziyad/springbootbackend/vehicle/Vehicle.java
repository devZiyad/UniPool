package me.devziyad.springbootbackend.vehicle;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.springbootbackend.user.User;

@Entity
@Table(name = "vehicles")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String make;       // e.g. Toyota
    private String model;      // e.g. Corolla
    private String color;
    private String plateNumber;

    private int seatCount;

    @ManyToOne(optional = false)
    private User owner;        // driver
}