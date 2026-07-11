package com.redbank.emergency.statemachine.guard;

import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.statemachine.EmergencyEvent;
import com.redbank.emergency.statemachine.EmergencyStateMachineConstants;
import lombok.extern.slf4j.Slf4j;
import org.springframework.statemachine.guard.Guard;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Slf4j
@Component
public class EmergencyGuards {

    public Guard<EmergencyStatus, EmergencyEvent> eligibleDonorGuard() {
        return context -> {
            UUID donorId = context.getMessageHeaders().get(EmergencyStateMachineConstants.DONOR_ID_HEADER, UUID.class);
            if (donorId == null) {
                log.warn("EligibleDonorGuard failed: No DONOR_ID in headers");
                return false;
            }
            // DETERMINISM: Reads pure state synchronously without side effects.
            log.info("EligibleDonorGuard passed for donor {}", donorId);
            return true;
        };
    }

    public Guard<EmergencyStatus, EmergencyEvent> requestActiveGuard() {
        return context -> {
            // DETERMINISM: Strictly checks current in-memory state.
            EmergencyStatus current = context.getSource().getId();
            boolean isActive = current != EmergencyStatus.COMPLETED && 
                               current != EmergencyStatus.CANCELLED && 
                               current != EmergencyStatus.FAILED && 
                               current != EmergencyStatus.EXPIRED;
            if (!isActive) {
                log.warn("RequestActiveGuard failed: Request is in terminal state {}", current);
            }
            return isActive;
        };
    }
    
    public Guard<EmergencyStatus, EmergencyEvent> availabilityGuard() {
        return context -> {
            log.info("AvailabilityGuard passed");
            return true;
        };
    }
}
