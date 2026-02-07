import 'package:flutter/material.dart';

import '../../../../core/services/feedback_service.dart';
import '../views/profile_view.dart';

class ProfilePage extends StatelessWidget {
  final FeedbackService? feedbackService;
  final VoidCallback? onShowTutorial;

  const ProfilePage({
    super.key,
    this.feedbackService,
    this.onShowTutorial,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileView(
      feedbackService: feedbackService,
      onShowTutorial: onShowTutorial,
    );
  }
}
