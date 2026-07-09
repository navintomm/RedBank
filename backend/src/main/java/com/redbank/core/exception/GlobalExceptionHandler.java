package com.redbank.core.exception;

import com.redbank.core.dto.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(AuthException.class)
    public ResponseEntity<ApiResponse<Void>> handleAuthException(AuthException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error(ex.getMessage()));
    }

    @ExceptionHandler(TokenRefreshException.class)
    public ResponseEntity<ApiResponse<Void>> handleTokenRefreshException(TokenRefreshException ex) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(ex.getMessage()));
    }
    
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiResponse<Void>> handleAccessDeniedException(AccessDeniedException ex) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error("Access denied."));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Map<String, String>>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error -> 
            errors.put(error.getField(), error.getDefaultMessage()));
        
        ApiResponse<Map<String, String>> response = new ApiResponse<>();
        response.setSuccess(false);
        response.setMessage("Validation failed");
        response.setData(errors);
        
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleGenericException(Exception ex) {
        // In production, do not expose stack trace
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("An unexpected error occurred."));
    }
}
