package me.devziyad.unipoolbackend.rating;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.unipoolbackend.booking.Booking;
import me.devziyad.unipoolbackend.user.User;

import java.time.LocalDateTime;

@Entity
@Table(name = "ratings", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"booking_id", "from_user_id"})
}, indexes = {
    @Index(name = "idx_rating_from_user_id", columnList = "from_user_id"),
    @Index(name = "idx_rating_to_user_id", columnList = "to_user_id"),
    @Index(name = "idx_rating_booking_id", columnList = "booking_id")
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
    @JoinColumn(name = "booking_id", unique = true, nullable = false)
    private Booking booking;

    @Column(nullable = false)
    @jakarta.validation.constraints.Min(value = 1, message = "Score must be at least 1")
    @jakarta.validation.constraints.Max(value = 5, message = "Score must be at most 5")
    private Integer score;

    @Column(columnDefinition = "TEXT")
    private String comment;

    @Column(nullable = false, updatable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}