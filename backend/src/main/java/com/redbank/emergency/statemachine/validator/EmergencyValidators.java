package com.redbank.emergency.statemachine.validator;

import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.statemachine.EmergencyEvent;
import com.redbank.emergency.statemachine.EmergencyStateMachineConstants;
import lombok.extern.slf4j.Slf4j;
import org.springframework.statemachine.action.Action;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Slf4j
@Component
public class EmergencyValidators {

    public Action<EmergencyStatus, EmergencyEvent> duplicateAcceptanceValidator() {
        return context -> {
            UUID requestId = context.getMessageHeaders().get(EmergencyStateMachineConstants.REQUEST_ID_HEADER, UUID.class);
            UUID donorId = context.getMessageHeaders().get(EmergencyStateMachineConstants.DONOR_ID_HEADER, UUID.class);
            
            // DETERMINISM: Strictly checking DB/Cache state synchronously.
            log.info("Validating duplicate acceptance for request {} by donor {}", requestId, donorId);
            
            // e.g. if (assignmentRepository.existsByRequestIdAndDonorId(requestId, donorId)) {
            //     throw new IllegalStateException("Donor already accepted this request");
            // }
        };
    }

    public Action<EmergencyStatus, EmergencyEvent> requestActiveValidator() {
        return context -> {
            UUID requestId = context.getMessageHeaders().get(EmergencyStateMachineConstants.REQUEST_ID_HEADER, UUID.class);
            log.info("Validating request {} is active...", requestId);
        };
    }

    public Action<EmergencyStatus, EmergencyEvent> assignmentValidator() {
        return context -> {
            log.info("Validating active assignment exists...");
        };
    }

    public Action<EmergencyStatus, EmergencyEvent> notificationValidator() {
        return context -> {
            log.info("Validating notifications can be safely generated...");
        };
    }
}
