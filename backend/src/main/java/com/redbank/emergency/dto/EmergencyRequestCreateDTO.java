package com.redbank.emergency.dto;

import com.redbank.donor.entity.BloodGroup;
import com.redbank.emergency.enums.EmergencyPriority;
import com.redbank.emergency.enums.EmergencyType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.DecimalMax;
import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmergencyRequestCreateDTO {
    
    private UUID hospitalId;
    
    @NotBlank(message = "Patient name is required")
    private String patientName;
    
    @Min(value = 0, message = "Age cannot be negative")
    private Integer patientAge;
    
    private com.redbank.donor.entity.Gender patientGender;
    
    @NotNull(message = "Blood group is required")
    private BloodGroup bloodGroup;
    
    @Builder.Default
    private EmergencyType emergencyType = EmergencyType.WHOLE_BLOOD;
    
    @Min(value = 1, message = "At least 1 unit is required")
    private Integer unitsRequired;
    
    @NotBlank(message = "Hospital name is required")
    private String hospitalName;
    
    private String hospitalAddress;
    
    @NotBlank(message = "City is required")
    private String city;
    
    private String pincode;
    
    @DecimalMin("-90.0")
    @DecimalMax("90.0")
    private BigDecimal latitude;
    
    @DecimalMin("-180.0")
    @DecimalMax("180.0")
    private BigDecimal longitude;
    
    @Builder.Default
    private EmergencyPriority priority = EmergencyPriority.EMERGENCY;
}
