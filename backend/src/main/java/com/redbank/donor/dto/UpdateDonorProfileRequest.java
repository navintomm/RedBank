package com.redbank.donor.dto;

import com.redbank.donor.entity.BloodGroup;
import com.redbank.donor.entity.Gender;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class UpdateDonorProfileRequest {
    
    @NotNull(message = "Blood group is required")
    private BloodGroup bloodGroup;
    
    @Past(message = "Date of birth must be in the past")
    private LocalDate dateOfBirth;
    
    private Gender gender;
    
    @DecimalMin(value = "30.0", message = "Weight must be valid")
    @DecimalMax(value = "300.0", message = "Weight must be valid")
    private BigDecimal weight;
    
    private String district;
    
    private String city;
    
    @DecimalMin(value = "-90.0")
    @DecimalMax(value = "90.0")
    private BigDecimal latitude;
    
    @DecimalMin(value = "-180.0")
    @DecimalMax(value = "180.0")
    private BigDecimal longitude;
    
    @Past(message = "Last donation date must be in the past")
    private LocalDate lastDonationDate;
    
    private String medicalNotes;
}
