package com.redbank.emergency.statemachine.listener;

import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.statemachine.EmergencyEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.statemachine.listener.StateMachineListenerAdapter;
import org.springframework.statemachine.state.State;

@Slf4j
public class EmergencyStateMachineListener extends StateMachineListenerAdapter<EmergencyStatus, EmergencyEvent> {

    @Override
    public void stateChanged(State<EmergencyStatus, EmergencyEvent> from, State<EmergencyStatus, EmergencyEvent> to) {
        log.info("State changed from {} to {}", 
                 from != null ? from.getId() : "NONE", 
                 to != null ? to.getId() : "NONE");
    }

    @Override
    public void stateMachineError(org.springframework.statemachine.StateMachine<EmergencyStatus, EmergencyEvent> stateMachine, Exception exception) {
        log.error("State Machine Error: {}", exception.getMessage());
    }
}
