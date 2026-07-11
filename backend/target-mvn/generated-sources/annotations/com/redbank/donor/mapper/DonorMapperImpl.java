package com.redbank.donor.mapper;

import com.redbank.auth.entity.User;
import com.redbank.donor.dto.DonorProfileDto;
import com.redbank.donor.entity.DonorProfile;
import java.util.UUID;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-07-11T10:25:32+0530",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 17.0.12 (Oracle Corporation)"
)
@Component
public class DonorMapperImpl implements DonorMapper {

    @Override
    public DonorProfileDto toDto(DonorProfile donorProfile) {
        if ( donorProfile == null ) {
            return null;
        }

        DonorProfileDto.DonorProfileDtoBuilder donorProfileDto = DonorProfileDto.builder();

        donorProfileDto.userId( donorProfileUserId( donorProfile ) );
        donorProfileDto.id( donorProfile.getId() );
        donorProfileDto.bloodGroup( donorProfile.getBloodGroup() );
        donorProfileDto.dateOfBirth( donorProfile.getDateOfBirth() );
        donorProfileDto.gender( donorProfile.getGender() );
        donorProfileDto.weight( donorProfile.getWeight() );
        donorProfileDto.district( donorProfile.getDistrict() );
        donorProfileDto.city( donorProfile.getCity() );
        donorProfileDto.latitude( donorProfile.getLatitude() );
        donorProfileDto.longitude( donorProfile.getLongitude() );
        donorProfileDto.lastDonationDate( donorProfile.getLastDonationDate() );
        donorProfileDto.availabilityStatus( donorProfile.getAvailabilityStatus() );
        donorProfileDto.verificationLevel( donorProfile.getVerificationLevel() );
        donorProfileDto.medicalNotes( donorProfile.getMedicalNotes() );
        donorProfileDto.profileImageUrl( donorProfile.getProfileImageUrl() );

        return donorProfileDto.build();
    }

    private UUID donorProfileUserId(DonorProfile donorProfile) {
        if ( donorProfile == null ) {
            return null;
        }
        User user = donorProfile.getUser();
        if ( user == null ) {
            return null;
        }
        UUID id = user.getId();
        if ( id == null ) {
            return null;
        }
        return id;
    }
}
