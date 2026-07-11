package com.redbank.emergency.service.impl;

import com.redbank.emergency.service.ReliabilityService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReliabilityServiceImpl implements ReliabilityService {

    @Async
    @Override
    public void penalizeNoShow(UUID donorId, UUID requestId) {
        // ASYNC BOUNDARY: This is isolated from the main request flow so 
        // reliability algorithms and historical aggregations do not lock active requests.
        log.info("ASYNC: Applying heavy reliability penalty to donor {} for No-Show on request {}", donorId, requestId);
    }
}
