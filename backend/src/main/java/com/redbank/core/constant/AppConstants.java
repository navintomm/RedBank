package com.redbank.core.constant;

public final class AppConstants {
    private AppConstants() {}

    public static final int DONATION_COOLDOWN_DAYS = 90;
    public static final int MIN_DONOR_AGE = 18;
    public static final int MAX_DONOR_AGE = 65;

    public static final String ERR_DONOR_NOT_FOUND = "Donor profile not found";
    public static final String ERR_USER_NOT_FOUND = "User not found";
    public static final String ERR_COOLDOWN_ACTIVE = "Cannot mark as available. Donor is still in the 90-day cooldown period.";
    public static final String ERR_INVALID_AGE = "Donor must be between 18 and 65 years of age";
}
