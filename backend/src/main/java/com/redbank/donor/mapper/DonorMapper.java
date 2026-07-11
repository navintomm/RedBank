package com.redbank.donor.mapper;

import com.redbank.donor.dto.DonorProfileDto;
import com.redbank.donor.entity.DonorProfile;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface DonorMapper {

    @Mapping(target = "userId", source = "user.id")
    DonorProfileDto toDto(DonorProfile donorProfile);
}
