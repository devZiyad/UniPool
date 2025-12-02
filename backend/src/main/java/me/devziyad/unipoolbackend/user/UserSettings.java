package me.devziyad.unipoolbackend.user;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "user_settings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSettings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(optional = false)
    @JoinColumn(name = "user_id", unique = true)
    private User user;

    @Column(nullable = false)
    @Builder.Default
    private Boolean emailNotifications = true;

    @Column(nullable = false)
    @Builder.Default
    private Boolean smsNotifications = false;

    @Column(nullable = false)
    @Builder.Default
    private Boolean pushNotifications = true;

    @Column(nullable = false)
    @Builder.Default
    private Boolean allowSmoking = false;

    @Column(nullable = false)
    @Builder.Default
    private Boolean allowPets = false;

    @Column(nullable = false)
    @Builder.Default
    private Boolean allowMusic = true;

    @Column(nullable = false)
    @Builder.Default
    private Boolean preferQuietRides = false;

    @Column(nullable = false)
    @Builder.Default
    private Boolean showPhoneNumber = true;

    @Column(nullable = false)
    @Builder.Default
    private Boolean showEmail = false;

    @Column(nullable = false)
    @Builder.Default
    private Boolean autoAcceptBookings = false;

    private String preferredPaymentMethod;
}