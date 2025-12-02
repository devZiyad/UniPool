package me.devziyad.unipoolbackend.user.dto;

import lombok.Data;

@Data
public class UpdateSettingsRequest {
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