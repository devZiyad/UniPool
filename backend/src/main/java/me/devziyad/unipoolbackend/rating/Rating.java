package me.devziyad.unipoolbackend.rating;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.booking.Booking;
import me.devziyad.unipoolbackend.user.User;

import java.time.LocalDateTime;

@Entity
@Table(name = "ratings", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"booking_id", "from_user_id"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Rating {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "from_user_id")
    private User fromUser;

    @ManyToOne(optional = false)
    @JoinColumn(name = "to_user_id")
    private User toUser;

    @OneToOne(optional = false)
    @JoinColumn(name = "booking_id", unique = true)
    private Booking booking;

    @Column(nullable = false)
    private Integer score;

    @Column(columnDefinition = "TEXT")
    private String comment;

    @Column(nullable = false, updatable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}