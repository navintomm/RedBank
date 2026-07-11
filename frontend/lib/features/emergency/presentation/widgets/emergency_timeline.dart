import 'package:flutter/material.dart';
import 'emergency_timeline_tile.dart';

class EmergencyTimeline extends StatelessWidget {
  final String currentStatus;

  const EmergencyTimeline({
    super.key,
    required this.currentStatus,
  });

  static const List<String> _orderedStages = [
    'DRAFT',
    'CREATED',
    'SEARCHING',
    'DONORS_IDENTIFIED', // Maps to Notifications Sent / Awaiting logically
    'NOTIFICATIONS_SENT',
    'AWAITING_RESPONSES',
    'ACCEPTED',
    'DONOR_TRAVELLING',
    'ARRIVED',
    'DONATION_IN_PROGRESS',
    'COMPLETED'
  ];

  static const List<String> _terminalErrors = [
    'CANCELLED',
    'FAILED',
    'EXPIRED',
    'NO_SHOW'
  ];

  @override
  Widget build(BuildContext context) {
    final statusUpper = currentStatus.toUpperCase();
    final isError = _terminalErrors.contains(statusUpper);
    final currentIndex = _orderedStages.indexOf(statusUpper);

    // Filter down to the stages we actually want to display
    final displayStages = [
      {'key': 'CREATED', 'title': 'Request Created', 'subtitle': 'Emergency registered'},
      {'key': 'SEARCHING', 'title': 'Searching', 'subtitle': 'Finding eligible donors'},
      {'key': 'AWAITING_RESPONSES', 'title': 'Awaiting Responses', 'subtitle': 'Donors notified'},
      {'key': 'ACCEPTED', 'title': 'Accepted', 'subtitle': 'A donor accepted the request'},
      {'key': 'DONOR_TRAVELLING', 'title': 'Travelling', 'subtitle': 'Donor is on the way'},
      {'key': 'ARRIVED', 'title': 'Arrived', 'subtitle': 'Donor arrived at hospital'},
      {'key': 'DONATION_IN_PROGRESS', 'title': 'In Progress', 'subtitle': 'Donation is happening'},
      {'key': 'COMPLETED', 'title': 'Completed', 'subtitle': 'Blood successfully donated'},
    ];

    if (isError) {
      displayStages.add({'key': statusUpper, 'title': statusUpper, 'subtitle': 'Request terminated'});
    }

    return Column(
      children: List.generate(displayStages.length, (index) {
        final stage = displayStages[index];
        final stageKey = stage['key']!;
        
        bool isCompleted = false;
        bool isCurrent = false;

        if (isError) {
          if (index == displayStages.length - 1) {
            isCurrent = true;
          } else {
            // Determine if this step happened before the error
            // For simplicity, we just mark past steps completed if they were likely reached.
            isCompleted = true; // Needs actual history log to be perfectly accurate
          }
        } else {
          final stageIndex = _orderedStages.indexOf(stageKey);
          if (currentIndex >= 0 && stageIndex >= 0) {
            if (stageIndex < currentIndex) {
              isCompleted = true;
            } else if (stageIndex == currentIndex || 
                (currentIndex == _orderedStages.indexOf('DONORS_IDENTIFIED') && stageKey == 'AWAITING_RESPONSES') ||
                (currentIndex == _orderedStages.indexOf('NOTIFICATIONS_SENT') && stageKey == 'AWAITING_RESPONSES') ||
                (currentIndex == _orderedStages.indexOf('DRAFT') && stageKey == 'CREATED')) {
              isCurrent = true;
            }
          }
        }

        return EmergencyTimelineTile(
          title: stage['title']!,
          subtitle: stage['subtitle']!,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isError: isCurrent && isError,
          isLast: index == displayStages.length - 1,
        );
      }),
    );
  }
}
