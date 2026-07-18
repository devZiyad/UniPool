package me.devziyad.unipoolbackend.audit;

public enum ActionType {
    // Authentication
    LOGIN,
    LOGOUT,
    REGISTER,
    PASSWORD_CHANGE,
    
    // Ride operations
    RIDE_CREATE,
    RIDE_UPDATE,
    RIDE_CANCEL,
    RIDE_COMPLETE,
    
    // Booking operations
    BOOKING_CREATE,
    BOOKING_CANCEL,
    
    // Payment operations
    PAYMENT_INITIATE,
    PAYMENT_COMPLETE,
    
    // Profile operations
    PROFILE_UPDATE,
    SETTINGS_UPDATE,
    
    // Moderation operations
    USER_REPORT,
    USER_BAN,
    USER_SUSPEND,
    USER_UNBAN,
    REPORT_RESOLVE,
    
    // Admin operations
    DATABASE_RESET,
    USER_ENABLE,
    USER_DISABLE
}

