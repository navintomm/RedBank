package com.redbank.auth.controller;

import com.redbank.auth.dto.AuthResponse;
import com.redbank.auth.dto.RefreshRequest;
import com.redbank.auth.dto.VerifyRequest;
import com.redbank.auth.service.AuthService;
import com.redbank.core.dto.ApiResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class AuthControllerTest {

    @Mock
    private AuthService authService;

    @InjectMocks
    private AuthController authController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testVerify_Success() {
        VerifyRequest request = new VerifyRequest("valid-firebase-token", "ROLE_DONOR");
        AuthResponse expectedResponse = new AuthResponse("jwt", "refresh", null, true);
        
        when(authService.verifyAndLogin(any(VerifyRequest.class))).thenReturn(expectedResponse);

        ResponseEntity<ApiResponse<AuthResponse>> response = authController.verify(request);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.getBody().isSuccess());
        assertEquals("jwt", response.getBody().getData().accessToken());
        verify(authService, times(1)).verifyAndLogin(request);
    }

    @Test
    void testRefreshToken_Success() {
        RefreshRequest request = new RefreshRequest("valid-refresh-token");
        AuthResponse expectedResponse = new AuthResponse("new-jwt", "valid-refresh-token", null, false);

        when(authService.refreshToken(any(RefreshRequest.class))).thenReturn(expectedResponse);

        ResponseEntity<ApiResponse<AuthResponse>> response = authController.refreshToken(request);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("new-jwt", response.getBody().getData().accessToken());
    }
}
