import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:eu_sou/features/feedback/views/about_view.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:eu_sou/core/services/feedback_service.dart';

class UserProfileViewModel extends BaseViewModel {
  final _navigationService = NavigationService();
  final _feedbackService = FeedbackService();

  void navigateToAbout() {
    _navigationService.navigateWithTransition(
      const AboutView(),
      transitionStyle: Transition.rightToLeft,
    );
  }

  void showFeedback(BuildContext context) {
    BetterFeedback.of(context).show((UserFeedback feedback) async {
      await _feedbackService.sendFeedback(
        feedback.text,
        feedback.screenshot,
      );

      // Show confirmation
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Obrigado pelo seu feedback!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}
