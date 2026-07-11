package com.redbank.core.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.BAD_REQUEST)
public class DonorValidationException extends RuntimeException {
    public DonorValidationException(String message) {
        super(message);
    }
}
