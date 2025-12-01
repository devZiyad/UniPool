package me.devziyad.springbootbackend.rating;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.springbootbackend.booking.Booking;
import me.devziyad.springbootbackend.user.User;

@Entity
@Table(name = "ratings")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Rating {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    private User fromUser;

    @ManyToOne(optional = false)
    private User toUser;

    @OneToOne(optional = false)
    private Booking booking;  // ensures rating only after ride

    private int score;        // 1–5
    private String comment;
}