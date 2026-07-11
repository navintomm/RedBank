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

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmergencyRequestCreateDTO {
    
    private UUID hospitalId;
    
    @NotBlank(message = "Patient name is required")
    private String patientName;
    
    @NotNull(message = "Blood group is required")
    private BloodGroup bloodGroup;
    
    private EmergencyType emergencyType = EmergencyType.WHOLE_BLOOD;
    
    @Min(value = 1, message = "At least 1 unit is required")
    private Integer unitsRequired;
    
    @NotBlank(message = "Hospital name is required")
    private String hospitalName;
    
    private String hospitalAddress;
    
    @NotBlank(message = "City is required")
    private String city;
    
    private String pincode;
    
    private Double latitude;
    
    private Double longitude;
    
    private EmergencyPriority priority = EmergencyPriority.EMERGENCY;
}
