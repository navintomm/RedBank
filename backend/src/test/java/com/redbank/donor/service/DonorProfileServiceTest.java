package com.redbank.donor.service;

import com.redbank.auth.entity.User;
import com.redbank.auth.repository.UserRepository;
import com.redbank.core.exception.DonorNotFoundException;
import com.redbank.donor.dto.DonorProfileDto;
import com.redbank.donor.dto.UpdateAvailabilityRequest;
import com.redbank.donor.dto.UpdateDonorProfileRequest;
import com.redbank.donor.entity.AvailabilityStatus;
import com.redbank.donor.entity.BloodGroup;
import com.redbank.donor.entity.DonorProfile;
import com.redbank.donor.mapper.DonorMapper;
import com.redbank.donor.repository.DonorRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class DonorProfileServiceTest {

    @Mock private DonorRepository donorRepository;
    @Mock private UserRepository userRepository;
    @Mock private DonorMapper donorMapper;
    @Mock private LocationService locationService;
    @Mock private EligibilityService eligibilityService;
    @Mock private AvailabilityService availabilityService;

    @InjectMocks
    private DonorProfileService donorProfileService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testCreateOrUpdateProfile_Success() {
        UUID userId = UUID.randomUUID();
        UpdateDonorProfileRequest request = new UpdateDonorProfileRequest();
        request.setBloodGroup(BloodGroup.O_POSITIVE);
        request.setDateOfBirth(LocalDate.now().minusYears(30));
        
        User user = new User();
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(donorRepository.findByUserIdAndIsDeletedFalse(userId)).thenReturn(Optional.empty());
        
        DonorProfile savedProfile = new DonorProfile();
        savedProfile.setBloodGroup(BloodGroup.O_POSITIVE);
        when(donorRepository.save(any(DonorProfile.class))).thenReturn(savedProfile);
        
        DonorProfileDto dto = DonorProfileDto.builder().bloodGroup(BloodGroup.O_POSITIVE).build();
        when(donorMapper.toDto(any())).thenReturn(dto);

        DonorProfileDto result = donorProfileService.createOrUpdateProfile(userId, request);

        assertNotNull(result);
        verify(eligibilityService).validateAge(any());
        verify(locationService).createPoint(any(), any());
        verify(availabilityService).updateAvailabilityBasedOnCooldown(any());
        verify(donorRepository).save(any(DonorProfile.class));
    }

    @Test
    void testUpdateAvailability_Success() {
        UUID userId = UUID.randomUUID();
        UpdateAvailabilityRequest request = new UpdateAvailabilityRequest(AvailabilityStatus.AVAILABLE);

        DonorProfile profile = new DonorProfile();
        when(donorRepository.findByUserIdAndIsDeletedFalse(userId)).thenReturn(Optional.of(profile));
        
        DonorProfile savedProfile = new DonorProfile();
        when(donorRepository.save(profile)).thenReturn(savedProfile);
        
        DonorProfileDto dto = DonorProfileDto.builder().build();
        when(donorMapper.toDto(savedProfile)).thenReturn(dto);

        DonorProfileDto result = donorProfileService.updateAvailability(userId, request);

        assertNotNull(result);
        verify(availabilityService).validateCooldownForAvailability(any(), eq(AvailabilityStatus.AVAILABLE));
        verify(donorRepository).save(profile);
        assertEquals(AvailabilityStatus.AVAILABLE, profile.getAvailabilityStatus());
    }

    @Test
    void testGetProfile_NotFound() {
        UUID userId = UUID.randomUUID();
        when(donorRepository.findByUserIdAndIsDeletedFalse(userId)).thenReturn(Optional.empty());

        assertThrows(DonorNotFoundException.class, () -> donorProfileService.getProfileByUserId(userId));
    }
}
