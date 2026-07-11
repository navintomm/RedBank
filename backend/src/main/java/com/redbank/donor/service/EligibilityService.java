package com.redbank.donor.service;

import com.redbank.core.constant.AppConstants;
import com.redbank.core.exception.DonorValidationException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@Service
public class EligibilityService {
    
    public void validateAge(LocalDate dateOfBirth) {
        if (dateOfBirth != null) {
            long age = ChronoUnit.YEARS.between(dateOfBirth, LocalDate.now());
            if (age < AppConstants.MIN_DONOR_AGE || age > AppConstants.MAX_DONOR_AGE) {
                throw new DonorValidationException(AppConstants.ERR_INVALID_AGE);
            }
        }
    }
}
