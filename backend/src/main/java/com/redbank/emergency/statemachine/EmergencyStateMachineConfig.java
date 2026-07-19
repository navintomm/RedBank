package com.redbank.emergency.statemachine;

import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.statemachine.action.EmergencyActions;
import com.redbank.emergency.statemachine.guard.EmergencyGuards;
import com.redbank.emergency.statemachine.listener.EmergencyStateMachineListener;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;
import org.springframework.statemachine.config.EnableStateMachineFactory;
import org.springframework.statemachine.config.EnumStateMachineConfigurerAdapter;
import org.springframework.statemachine.config.builders.StateMachineConfigurationConfigurer;
import org.springframework.statemachine.config.builders.StateMachineStateConfigurer;
import org.springframework.statemachine.config.builders.StateMachineTransitionConfigurer;



@Slf4j
@Configuration
@EnableStateMachineFactory(name = "emergencyStateMachineFactory")
@RequiredArgsConstructor
public class EmergencyStateMachineConfig extends EnumStateMachineConfigurerAdapter<EmergencyStatus, EmergencyEvent> {

    private final EmergencyGuards guards;
    private final EmergencyActions actions;

    @Override
    public void configure(StateMachineConfigurationConfigurer<EmergencyStatus, EmergencyEvent> config) throws Exception {
        config
            .withConfiguration()
            .autoStartup(false)
            .listener(new EmergencyStateMachineListener());
    }

    @Override
    public void configure(StateMachineStateConfigurer<EmergencyStatus, EmergencyEvent> states) throws Exception {
        states
            .withStates()
            .initial(EmergencyStatus.DRAFT)
            .state(EmergencyStatus.CREATED)
            .state(EmergencyStatus.SEARCHING)
            .state(EmergencyStatus.DONORS_IDENTIFIED)
            .state(EmergencyStatus.NOTIFICATIONS_SENT)
            .state(EmergencyStatus.AWAITING_RESPONSES)
            .state(EmergencyStatus.ACCEPTED)
            .state(EmergencyStatus.DONOR_TRAVELLING)
            .state(EmergencyStatus.ARRIVED)
            .state(EmergencyStatus.DONATION_IN_PROGRESS)
            .end(EmergencyStatus.COMPLETED)
            .end(EmergencyStatus.CANCELLED)
            .end(EmergencyStatus.EXPIRED)
            .end(EmergencyStatus.FAILED);
    }

    @Override
    public void configure(StateMachineTransitionConfigurer<EmergencyStatus, EmergencyEvent> transitions) throws Exception {
        transitions
            // Happy Path Core
            .withExternal()
                .source(EmergencyStatus.DRAFT).target(EmergencyStatus.CREATED)
                .event(EmergencyEvent.CREATE_REQUEST)
                .action(actions.errorAction())
                .and()
            .withExternal()
                .source(EmergencyStatus.CREATED).target(EmergencyStatus.SEARCHING)
                .event(EmergencyEvent.START_SEARCH)
                .guard(guards.requestActiveGuard())
                .and()
            .withExternal()
                .source(EmergencyStatus.SEARCHING).target(EmergencyStatus.DONORS_IDENTIFIED)
                .event(EmergencyEvent.DONORS_FOUND)
                .and()
            .withExternal()
                .source(EmergencyStatus.DONORS_IDENTIFIED).target(EmergencyStatus.NOTIFICATIONS_SENT)
                .event(EmergencyEvent.SEND_NOTIFICATIONS)
                .action(actions.queueNotificationsAction())
                .and()
            .withExternal()
                .source(EmergencyStatus.NOTIFICATIONS_SENT).target(EmergencyStatus.AWAITING_RESPONSES)
                .event(EmergencyEvent.TIMEOUT) // Sent to Wait State
                .and()
                
            // Acceptance
            .withExternal()
                .source(EmergencyStatus.AWAITING_RESPONSES).target(EmergencyStatus.ACCEPTED)
                .event(EmergencyEvent.DONOR_ACCEPTED)
                .guard(guards.eligibleDonorGuard())
                .action(actions.updateAssignmentAction())
                .and()
                
            // Travel & Donation
            .withExternal()
                .source(EmergencyStatus.ACCEPTED).target(EmergencyStatus.DONOR_TRAVELLING)
                .event(EmergencyEvent.START_TRAVEL)
                .and()
            .withExternal()
                .source(EmergencyStatus.DONOR_TRAVELLING).target(EmergencyStatus.ARRIVED)
                .event(EmergencyEvent.ARRIVED_AT_LOCATION)
                .action(actions.donorArrivedAction())
                .and()
            .withExternal()
                .source(EmergencyStatus.ARRIVED).target(EmergencyStatus.DONATION_IN_PROGRESS)
                .event(EmergencyEvent.START_DONATION)
                .and()
            .withExternal()
                .source(EmergencyStatus.DONATION_IN_PROGRESS).target(EmergencyStatus.COMPLETED)
                .event(EmergencyEvent.COMPLETE_REQUEST)
                .and()
                
            // Cancellations (From almost any active state)
            .withExternal()
                .source(EmergencyStatus.DRAFT).target(EmergencyStatus.CANCELLED)
                .event(EmergencyEvent.CANCEL_REQUEST)
                .and()
            .withExternal()
                .source(EmergencyStatus.CREATED).target(EmergencyStatus.CANCELLED)
                .event(EmergencyEvent.CANCEL_REQUEST)
                .and()
            .withExternal()
                .source(EmergencyStatus.SEARCHING).target(EmergencyStatus.CANCELLED)
                .event(EmergencyEvent.CANCEL_REQUEST)
                .and()
            .withExternal()
                .source(EmergencyStatus.AWAITING_RESPONSES).target(EmergencyStatus.CANCELLED)
                .event(EmergencyEvent.CANCEL_REQUEST)
                .and()
            .withExternal()
                .source(EmergencyStatus.ACCEPTED).target(EmergencyStatus.CANCELLED)
                .event(EmergencyEvent.CANCEL_REQUEST)
                .and()
            .withExternal()
                .source(EmergencyStatus.DONOR_TRAVELLING).target(EmergencyStatus.CANCELLED)
                .event(EmergencyEvent.CANCEL_REQUEST)
                .and()
                
            // Expirations & Timeouts
            .withExternal()
                .source(EmergencyStatus.AWAITING_RESPONSES).target(EmergencyStatus.EXPIRED)
                .event(EmergencyEvent.REQUEST_EXPIRED)
                .and()
            .withExternal()
                .source(EmergencyStatus.AWAITING_RESPONSES).target(EmergencyStatus.SEARCHING)
                .event(EmergencyEvent.RESTART_SEARCH)
                .action(actions.restartMatchingAction())
                .and()
                
            // No Show Recovery Workflow
            .withExternal()
                .source(EmergencyStatus.DONOR_TRAVELLING).target(EmergencyStatus.NO_SHOW)
                .event(EmergencyEvent.DONOR_NO_SHOW)
                .action(actions.applyReliabilityPenaltyAction())
                .and()
            .withExternal()
                .source(EmergencyStatus.NO_SHOW).target(EmergencyStatus.SEARCHING)
                .event(EmergencyEvent.RESTART_SEARCH)
                .action(actions.restartMatchingAction());
    }
}
