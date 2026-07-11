package com.redbank.donor.service;

import com.redbank.core.exception.DonorValidationException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertThrows;

class EligibilityServiceTest {

    private EligibilityService eligibilityService;

    @BeforeEach
    void setUp() {
        eligibilityService = new EligibilityService();
    }

    @Test
    void testValidateAge_Underage_ThrowsException() {
        LocalDate underage = LocalDate.now().minusYears(17);
        assertThrows(DonorValidationException.class, () -> eligibilityService.validateAge(underage));
    }

    @Test
    void testValidateAge_Overage_ThrowsException() {
        LocalDate overage = LocalDate.now().minusYears(66);
        assertThrows(DonorValidationException.class, () -> eligibilityService.validateAge(overage));
    }

    @Test
    void testValidateAge_ValidAge_Success() {
        LocalDate validAge = LocalDate.now().minusYears(30);
        // Should not throw
        eligibilityService.validateAge(validAge);
    }
}
