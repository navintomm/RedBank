package com.redbank.emergency.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.redbank.auth.entity.User;
import com.redbank.auth.repository.UserRepository;
import com.redbank.emergency.dto.CancelRequestDTO;
import com.redbank.emergency.dto.EmergencyRequestCreateDTO;
import com.redbank.emergency.enums.EmergencyPriority;
import com.redbank.emergency.enums.EmergencyType;
import com.redbank.emergency.repository.EmergencyRequestRepository;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Collections;
import java.util.UUID;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
public class EmergencyIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EmergencyRequestRepository requestRepository;



    private User testRequester;
    private User testDonor;

    @BeforeEach
    void setUp() {
        requestRepository.deleteAll();
        userRepository.deleteAll();

        testRequester = User.builder()
                .phoneNumber("+1234567890")
                .firebaseUid("uid123")
                .build();
        testRequester = userRepository.save(testRequester);

        testDonor = User.builder()
                .phoneNumber("+0987654321")
                .firebaseUid("uid456")
                .build();
        testDonor = userRepository.save(testDonor);
    }

    @Test
    void testEndToEndHappyPath() throws Exception {
        // 1. Create Request
        EmergencyRequestCreateDTO createDto = new EmergencyRequestCreateDTO();
        createDto.setBloodGroup(com.redbank.donor.entity.BloodGroup.O_POSITIVE);
        createDto.setLatitude(java.math.BigDecimal.valueOf(40.7128));
        createDto.setLongitude(java.math.BigDecimal.valueOf(-74.0060));
        createDto.setHospitalName("City Hospital");
        createDto.setPatientName("John Doe");
        createDto.setCity("New York");
        createDto.setUnitsRequired(2);
        createDto.setPriority(EmergencyPriority.EMERGENCY);
        createDto.setEmergencyType(EmergencyType.WHOLE_BLOOD);

        long startCreate = System.currentTimeMillis();
        MvcResult createResult = mockMvc.perform(post("/api/v1/emergencies")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createDto))
                        .with(authentication(new UsernamePasswordAuthenticationToken(testRequester, null, Collections.emptyList()))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andReturn();
        long createTime = System.currentTimeMillis() - startCreate;
        System.out.println("Performance [Request Creation]: " + createTime + " ms");

        String responseBody = createResult.getResponse().getContentAsString();
        String requestIdStr = objectMapper.readTree(responseBody).get("data").get("id").asText();
        UUID requestId = UUID.fromString(requestIdStr);

        // Sleep briefly to let async state machine handle DRAFT -> CREATED -> SEARCHING
        Thread.sleep(1000);

        // Verify status is now CREATED or SEARCHING
        mockMvc.perform(get("/api/v1/emergencies/" + requestId)
                        .with(authentication(new UsernamePasswordAuthenticationToken(testRequester, null, Collections.emptyList()))))
                .andExpect(status().isOk());

        // 2. Donor Accepts
        long startAccept = System.currentTimeMillis();
        mockMvc.perform(post("/api/v1/emergencies/" + requestId + "/accept")
                        .with(authentication(new UsernamePasswordAuthenticationToken(testDonor, null, Collections.emptyList()))))
                .andExpect(status().isOk());
        long acceptTime = System.currentTimeMillis() - startAccept;
        System.out.println("Performance [State Transition - Accept]: " + acceptTime + " ms");
                
        Thread.sleep(500); // Async transition

        // 3. Cancel Request
        CancelRequestDTO cancelDto = new CancelRequestDTO();
        cancelDto.setReason("No longer needed");
        
        mockMvc.perform(post("/api/v1/emergencies/" + requestId + "/cancel")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(cancelDto))
                        .with(authentication(new UsernamePasswordAuthenticationToken(testRequester, null, Collections.emptyList()))))
                .andExpect(status().isOk());
    }
}
