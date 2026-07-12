package com.redbank.emergency.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.redbank.auth.entity.Role;
import com.redbank.auth.entity.User;
import com.redbank.auth.security.JwtProvider;
import com.redbank.emergency.dto.CancelRequestDTO;
import com.redbank.emergency.dto.EmergencyRequestCreateDTO;
import com.redbank.emergency.dto.EmergencyRequestResponseDTO;
import com.redbank.emergency.facade.EmergencyFacade;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
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

@WebMvcTest(EmergencyController.class)
@AutoConfigureMockMvc(addFilters = false) // Bypass standard security filters for unit tests
class EmergencyControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private EmergencyFacade emergencyFacade;

    @MockBean
    private JwtProvider jwtProvider;

    private User testUser;
    private EmergencyRequestCreateDTO createDTO;
    private EmergencyRequestResponseDTO responseDTO;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(UUID.randomUUID());
        testUser.setFirebaseUid("test-uid");
        testUser.setRoles(Set.of(new Role(1, "ROLE_DONOR")));

        createDTO = new EmergencyRequestCreateDTO();
        createDTO.setPatientName("Jane Doe");
        createDTO.setBloodGroup(com.redbank.donor.entity.BloodGroup.A_POSITIVE);
        createDTO.setEmergencyType(com.redbank.emergency.enums.EmergencyType.WHOLE_BLOOD);
        createDTO.setUnitsRequired(1);
        createDTO.setHospitalName("General Hospital");
        createDTO.setCity("Metropolis");
        createDTO.setLatitude(BigDecimal.valueOf(10.0));
        createDTO.setLongitude(BigDecimal.valueOf(20.0));
        createDTO.setPriority(com.redbank.emergency.enums.EmergencyPriority.EMERGENCY);

        responseDTO = new EmergencyRequestResponseDTO();
        responseDTO.setId(UUID.randomUUID());
        responseDTO.setPatientName("Jane Doe");
        responseDTO.setStatus(com.redbank.emergency.enums.EmergencyStatus.DRAFT);
    }

    @Test
    void createRequest_Success() throws Exception {
        when(emergencyFacade.createRequest(eq(testUser.getId()), any(EmergencyRequestCreateDTO.class)))
                .thenReturn(responseDTO);

        mockMvc.perform(post("/api/v1/emergencies")
                        .with(authentication(new UsernamePasswordAuthenticationToken(testUser, null, Collections.emptyList())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(responseDTO.getId().toString()))
                .andExpect(jsonPath("$.data.patientName").value("Jane Doe"));

        verify(emergencyFacade).createRequest(eq(testUser.getId()), any(EmergencyRequestCreateDTO.class));
    }

    @Test
    void createRequest_ValidationFailed() throws Exception {
        createDTO.setPatientName(null); // Invalid: missing required field

        mockMvc.perform(post("/api/v1/emergencies")
                        .with(authentication(new UsernamePasswordAuthenticationToken(testUser, null, Collections.emptyList())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createDTO)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void getRequest_Success() throws Exception {
        UUID requestId = responseDTO.getId();
        when(emergencyFacade.getRequest(requestId)).thenReturn(responseDTO);

        mockMvc.perform(get("/api/v1/emergencies/" + requestId)
                        .with(authentication(new UsernamePasswordAuthenticationToken(testUser, null, Collections.emptyList()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(requestId.toString()));

        verify(emergencyFacade).getRequest(requestId);
    }

    @Test
    void cancelRequest_Success() throws Exception {
        UUID requestId = UUID.randomUUID();
        CancelRequestDTO cancelDTO = new CancelRequestDTO();
        cancelDTO.setReason("Found donor locally");

        mockMvc.perform(post("/api/v1/emergencies/" + requestId + "/cancel")
                        .with(authentication(new UsernamePasswordAuthenticationToken(testUser, null, Collections.emptyList())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(cancelDTO)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(emergencyFacade).cancelRequest(requestId, testUser.getId(), "Found donor locally");
    }

    @Test
    void acceptRequest_Success() throws Exception {
        UUID requestId = UUID.randomUUID();

        mockMvc.perform(post("/api/v1/emergencies/" + requestId + "/accept")
                        .with(authentication(new UsernamePasswordAuthenticationToken(testUser, null, Collections.emptyList())))
                        .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(emergencyFacade).acceptRequest(requestId, testUser.getId());
    }
}
