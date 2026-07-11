package com.redbank.donor.service;

import com.redbank.core.exception.DonorValidationException;
import com.redbank.donor.entity.AvailabilityStatus;
import com.redbank.donor.entity.DonorProfile;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class AvailabilityServiceTest {

    private AvailabilityService availabilityService;

    @BeforeEach
    void setUp() {
        availabilityService = new AvailabilityService();
    }

    @Test
    void testValidateCooldownForAvailability_OnCooldown_ThrowsException() {
        LocalDate recentDonation = LocalDate.now().minusDays(10); // Within 90 days
        assertThrows(DonorValidationException.class, () ->
                availabilityService.validateCooldownForAvailability(recentDonation, AvailabilityStatus.AVAILABLE)
        );
    }

    @Test
    void testValidateCooldownForAvailability_OffCooldown_Success() {
        LocalDate oldDonation = LocalDate.now().minusDays(100); // Beyond 90 days
        // Should not throw
        availabilityService.validateCooldownForAvailability(oldDonation, AvailabilityStatus.AVAILABLE);
    }

    @Test
    void testUpdateAvailabilityBasedOnCooldown_SetsOnCooldown() {
        DonorProfile profile = new DonorProfile();
        profile.setLastDonationDate(LocalDate.now().minusDays(10));
        
        availabilityService.updateAvailabilityBasedOnCooldown(profile);
        
        assertEquals(AvailabilityStatus.ON_COOLDOWN, profile.getAvailabilityStatus());
    }

    @Test
    void testUpdateAvailabilityBasedOnCooldown_CooldownExpiry_SetsUnavailable() {
        DonorProfile profile = new DonorProfile();
        profile.setLastDonationDate(LocalDate.now().minusDays(100));
        profile.setAvailabilityStatus(AvailabilityStatus.ON_COOLDOWN); // Was previously on cooldown
        
        availabilityService.updateAvailabilityBasedOnCooldown(profile);
        
        assertEquals(AvailabilityStatus.UNAVAILABLE, profile.getAvailabilityStatus()); // Auto expires to unavailable
    }
}
