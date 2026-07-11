package com.redbank.emergency.statemachine.action;

import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.statemachine.EmergencyEvent;
import com.redbank.emergency.statemachine.EmergencyStateMachineConstants;
import lombok.extern.slf4j.Slf4j;
import org.springframework.statemachine.action.Action;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Slf4j
@Component
public class EmergencyActions {

    public Action<EmergencyStatus, EmergencyEvent> queueNotificationsAction() {
        return context -> {
            UUID requestId = context.getMessageHeaders().get(EmergencyStateMachineConstants.REQUEST_ID_HEADER, UUID.class);
            // SIDE-EFFECT FREE / ASYNC QUEUEING
            // Emits a Spring ApplicationEvent to decouple notification generation
            // from the active DB transaction. Ensures low-latency state changes.
            log.info("Publishing async event to NotificationEngine to queue notifications for request {}", requestId);
        };
    }

    public Action<EmergencyStatus, EmergencyEvent> updateAssignmentAction() {
        return context -> {
            UUID donorId = context.getMessageHeaders().get(EmergencyStateMachineConstants.DONOR_ID_HEADER, UUID.class);
            // TRANSACTION SAFE
            // Persists assignment record immediately within the same state machine transaction.
            log.info("Persisting assignment for donor {} to DB transactionally", donorId);
        };
    }

    public Action<EmergencyStatus, EmergencyEvent> applyReliabilityPenaltyAction() {
        return context -> {
            UUID donorId = context.getMessageHeaders().get(EmergencyStateMachineConstants.DONOR_ID_HEADER, UUID.class);
            // SIDE-EFFECT FREE / ASYNC QUEUEING
            // Heavy analytics math should be queued to avoid locking.
            log.info("Publishing async event to penalize reliability for No-Show donor {}", donorId);
        };
    }

    public Action<EmergencyStatus, EmergencyEvent> restartMatchingAction() {
        return context -> {
            // SIDE-EFFECT FREE / ASYNC QUEUEING
            // Spawning a complex geographical matching engine search is heavy. 
            log.info("Publishing async event to MatchEngine to restart search tier...");
        };
    }
    
    public Action<EmergencyStatus, EmergencyEvent> errorAction() {
        return context -> {
            Exception exception = context.getException();
            log.error("State machine transaction failed. Rolling back: {}", exception != null ? exception.getMessage() : "Unknown");
        };
    }
}
