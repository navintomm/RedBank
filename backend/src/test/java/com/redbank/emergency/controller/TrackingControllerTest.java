package com.redbank.emergency.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.redbank.auth.entity.Role;
import com.redbank.auth.entity.User;
import com.redbank.auth.security.JwtProvider;
import com.redbank.emergency.dto.TrackingLocationRequestDTO;
import com.redbank.emergency.dto.TrackingStatusResponseDTO;
import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.service.TrackingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.Set;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(TrackingController.class)
@AutoConfigureMockMvc(addFilters = false) // Bypass standard security filters for unit tests
class TrackingControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private TrackingService trackingService;

    @MockBean
    private JwtProvider jwtProvider;

    private User testUser;
    private UUID requestId;

    @BeforeEach
    void setUp() {
        requestId = UUID.randomUUID();
        
        testUser = new User();
        testUser.setId(UUID.randomUUID());
        testUser.setFirebaseUid("test-uid");
        testUser.setRoles(Set.of(new Role(1, "ROLE_DONOR")));
    }

    @Test
    void startTracking_Success() throws Exception {
        mockMvc.perform(post("/api/v1/emergencies/" + requestId + "/tracking/start")
                        .with(authentication(new UsernamePasswordAuthenticationToken(testUser, null, Collections.emptyList())))
                        .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(trackingService).startTracking(requestId, testUser.getId());
    }

    @Test
    void stopTracking_Success() throws Exception {
        mockMvc.perform(post("/api/v1/emergencies/" + requestId + "/tracking/stop")
                        .with(authentication(new UsernamePasswordAuthenticationToken(testUser, null, Collections.emptyList())))
                        .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(trackingService).stopTracking(requestId, testUser.getId());
    }

    @Test
    void updateLocation_Success() throws Exception {
        TrackingLocationRequestDTO locationDTO = new TrackingLocationRequestDTO();
        locationDTO.setLatitude(40.7128);
        locationDTO.setLongitude(-74.0060);
        locationDTO.setTimestamp(OffsetDateTime.now());

        mockMvc.perform(post("/api/v1/emergencies/" + requestId + "/tracking/location")
                        .with(authentication(new UsernamePasswordAuthenticationToken(testUser, null, Collections.emptyList())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(locationDTO)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(trackingService).updateLocation(eq(requestId), eq(testUser.getId()), any(TrackingLocationRequestDTO.class));
    }
    
    @Test
    void updateLocation_ValidationFailed() throws Exception {
        TrackingLocationRequestDTO locationDTO = new TrackingLocationRequestDTO();
        // Missing lat/lng

        mockMvc.perform(post("/api/v1/emergencies/" + requestId + "/tracking/location")
                        .with(authentication(new UsernamePasswordAuthenticationToken(testUser, null, Collections.emptyList())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(locationDTO)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void getTrackingStatus_Success() throws Exception {
        TrackingStatusResponseDTO statusDTO = new TrackingStatusResponseDTO();
        statusDTO.setRequestId(requestId);
        statusDTO.setDonorId(testUser.getId());
        statusDTO.setIsActive(true);
        statusDTO.setStatus(EmergencyStatus.DONOR_TRAVELLING);

        when(trackingService.getTrackingStatus(requestId, testUser.getId())).thenReturn(statusDTO);

        mockMvc.perform(get("/api/v1/emergencies/" + requestId + "/tracking")
                        .with(authentication(new UsernamePasswordAuthenticationToken(testUser, null, Collections.emptyList()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.status").value(EmergencyStatus.DONOR_TRAVELLING.name()));

        verify(trackingService).getTrackingStatus(requestId, testUser.getId());
    }
}
