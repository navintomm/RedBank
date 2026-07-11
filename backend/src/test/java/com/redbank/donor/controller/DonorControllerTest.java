package com.redbank.donor.controller;

import com.redbank.auth.entity.User;
import com.redbank.core.dto.ApiResponse;
import com.redbank.donor.dto.DonorProfileDto;
import com.redbank.donor.service.DonorProfileService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

class DonorControllerTest {

    @Mock
    private DonorProfileService donorService;

    @InjectMocks
    private DonorController donorController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testGetProfile_Success() {
        User mockUser = new User();
        mockUser.setId(UUID.randomUUID());

        DonorProfileDto mockDto = DonorProfileDto.builder().id(UUID.randomUUID()).build();
        when(donorService.getProfileByUserId(any())).thenReturn(mockDto);

        ResponseEntity<ApiResponse<DonorProfileDto>> response = donorController.getProfile(mockUser);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.getBody().isSuccess());
        assertEquals(mockDto, response.getBody().getData());
    }
}
