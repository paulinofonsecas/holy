import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';

/// A beautiful loading screen displayed while a Bible version is being loaded.
///
/// Features:
/// - Animated loading indicator with bounce effect
/// - Progress message with version name
/// - Subtle background animation
/// - Accessible and user-friendly design
class VersionLoaderScreen extends StatefulWidget {
  final String versionName;
  final String? message;

  const VersionLoaderScreen({
    super.key,
    required this.versionName,
    this.message,
  });

  @override
  State<VersionLoaderScreen> createState() => _VersionLoaderScreenState();
}

class _VersionLoaderScreenState extends State<VersionLoaderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated loading indicator
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: AppHugeIcon(
                        icon: HugeIcons.strokeRoundedSparkles,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Version name
              Text(
                'Loading ${widget.versionName}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Loading message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  widget.message ??
                      'Please wait while we prepare the verses for you...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              // Loading dots animation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final delay = index * 0.3;
                      final animationValue =
                          (_animationController.value + delay) % 1.0;
                      final scale =
                          0.5 + (animationValue * 0.5).abs().sign * 0.5;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: ScaleTransition(
                          scale: AlwaysStoppedAnimation(scale),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A lightweight loading indicator overlay for use within other screens.
///
/// Can be displayed over search results or other content while loading.
class VersionLoadingOverlay extends StatelessWidget {
  final String versionName;

  const VersionLoadingOverlay({
    super.key,
    required this.versionName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading ${versionName.toUpperCase()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
