package me.devziyad.unipoolbackend.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserSettingsResponse {
    private Long id;
    private Boolean emailNotifications;
    private Boolean smsNotifications;
    private Boolean pushNotifications;
    private Boolean allowSmoking;
    private Boolean allowPets;
    private Boolean allowMusic;
    private Boolean preferQuietRides;
    private Boolean showPhoneNumber;
    private Boolean showEmail;
    private Boolean autoAcceptBookings;
    private String preferredPaymentMethod;
}