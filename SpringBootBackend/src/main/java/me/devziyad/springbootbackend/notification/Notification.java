package me.devziyad.springbootbackend.notification;

import jakarta.persistence.*;
import lombok.*;
import me.devziyad.springbootbackend.common.NotificationType;
import me.devziyad.springbootbackend.user.User;

import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    private User user;

    @Enumerated(EnumType.STRING)
    private NotificationType type;

    private String title;
    private String body;

    private boolean read;

    private LocalDateTime createdAt;
}