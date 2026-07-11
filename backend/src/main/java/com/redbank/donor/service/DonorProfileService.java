package com.redbank.donor.service;

import com.redbank.auth.entity.User;
import com.redbank.auth.repository.UserRepository;
import com.redbank.core.constant.AppConstants;
import com.redbank.core.exception.DonorNotFoundException;
import com.redbank.donor.dto.DonorProfileDto;
import com.redbank.donor.dto.UpdateAvailabilityRequest;
import com.redbank.donor.dto.UpdateDonorProfileRequest;
import com.redbank.donor.entity.DonorProfile;
import com.redbank.donor.mapper.DonorMapper;
import com.redbank.donor.repository.DonorRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class DonorProfileService {

    private final DonorRepository donorRepository;
    private final UserRepository userRepository;
    private final DonorMapper donorMapper;
    private final LocationService locationService;
    private final EligibilityService eligibilityService;
    private final AvailabilityService availabilityService;

    public DonorProfileService(DonorRepository donorRepository, UserRepository userRepository, DonorMapper donorMapper,
                               LocationService locationService, EligibilityService eligibilityService, AvailabilityService availabilityService) {
        this.donorRepository = donorRepository;
        this.userRepository = userRepository;
        this.donorMapper = donorMapper;
        this.locationService = locationService;
        this.eligibilityService = eligibilityService;
        this.availabilityService = availabilityService;
    }

    @Transactional(readOnly = true)
    public DonorProfileDto getProfileByUserId(UUID userId) {
        DonorProfile profile = donorRepository.findByUserIdAndIsDeletedFalse(userId)
                .orElseThrow(() -> new DonorNotFoundException(AppConstants.ERR_DONOR_NOT_FOUND));
        return donorMapper.toDto(profile);
    }

    @Transactional
    public DonorProfileDto createOrUpdateProfile(UUID userId, UpdateDonorProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new DonorNotFoundException(AppConstants.ERR_USER_NOT_FOUND));

        eligibilityService.validateAge(request.getDateOfBirth());

        DonorProfile profile = donorRepository.findByUserIdAndIsDeletedFalse(userId)
                .orElse(new DonorProfile());

        if (profile.getId() == null) {
            profile.setUser(user);
        }

        profile.setBloodGroup(request.getBloodGroup());
        profile.setDateOfBirth(request.getDateOfBirth());
        profile.setGender(request.getGender());
        profile.setWeight(request.getWeight());
        profile.setDistrict(request.getDistrict());
        profile.setCity(request.getCity());
        profile.setLatitude(request.getLatitude());
        profile.setLongitude(request.getLongitude());
        profile.setLastDonationDate(request.getLastDonationDate());
        profile.setMedicalNotes(request.getMedicalNotes());

        profile.setLocation(locationService.createPoint(request.getLatitude(), request.getLongitude()));
        availabilityService.updateAvailabilityBasedOnCooldown(profile);

        DonorProfile saved = donorRepository.save(profile);
        return donorMapper.toDto(saved);
    }

    @Transactional
    public DonorProfileDto updateAvailability(UUID userId, UpdateAvailabilityRequest request) {
        DonorProfile profile = donorRepository.findByUserIdAndIsDeletedFalse(userId)
                .orElseThrow(() -> new DonorNotFoundException(AppConstants.ERR_DONOR_NOT_FOUND));

        availabilityService.validateCooldownForAvailability(profile.getLastDonationDate(), request.status());

        profile.setAvailabilityStatus(request.status());
        DonorProfile saved = donorRepository.save(profile);
        return donorMapper.toDto(saved);
    }

    @Transactional
    public void deleteProfile(UUID userId) {
        DonorProfile profile = donorRepository.findByUserIdAndIsDeletedFalse(userId)
                .orElseThrow(() -> new DonorNotFoundException(AppConstants.ERR_DONOR_NOT_FOUND));
        
        profile.setDeleted(true);
        donorRepository.save(profile);
    }
}
