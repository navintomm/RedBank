package com.redbank.donor.dto;

import com.redbank.donor.entity.AvailabilityStatus;
import com.redbank.donor.entity.BloodGroup;
import com.redbank.donor.entity.Gender;
import com.redbank.donor.entity.VerificationLevel;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Data
@Builder
public class DonorProfileDto {
    private UUID id;
    private UUID userId;
    private BloodGroup bloodGroup;
    private LocalDate dateOfBirth;
    private Gender gender;
    private BigDecimal weight;
    private String district;
    private String city;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private LocalDate lastDonationDate;
    private AvailabilityStatus availabilityStatus;
    private VerificationLevel verificationLevel;
    private String medicalNotes;
    private String profileImageUrl;
}
