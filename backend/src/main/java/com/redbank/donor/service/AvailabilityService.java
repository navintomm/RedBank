package com.redbank.donor.service;

import com.redbank.core.constant.AppConstants;
import com.redbank.core.exception.DonorValidationException;
import com.redbank.donor.entity.AvailabilityStatus;
import com.redbank.donor.entity.DonorProfile;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@Service
public class AvailabilityService {

    public void validateCooldownForAvailability(LocalDate lastDonationDate, AvailabilityStatus desiredStatus) {
        if (desiredStatus == AvailabilityStatus.AVAILABLE && lastDonationDate != null) {
            long daysSinceDonation = ChronoUnit.DAYS.between(lastDonationDate, LocalDate.now());
            if (daysSinceDonation < AppConstants.DONATION_COOLDOWN_DAYS) {
                throw new DonorValidationException(AppConstants.ERR_COOLDOWN_ACTIVE);
            }
        }
    }

    public void updateAvailabilityBasedOnCooldown(DonorProfile profile) {
        if (profile.getLastDonationDate() != null) {
            long daysSinceDonation = ChronoUnit.DAYS.between(profile.getLastDonationDate(), LocalDate.now());
            if (daysSinceDonation < AppConstants.DONATION_COOLDOWN_DAYS) {
                profile.setAvailabilityStatus(AvailabilityStatus.ON_COOLDOWN);
            } else if (profile.getAvailabilityStatus() == AvailabilityStatus.ON_COOLDOWN) {
                profile.setAvailabilityStatus(AvailabilityStatus.UNAVAILABLE);
            }
        }
    }
}
