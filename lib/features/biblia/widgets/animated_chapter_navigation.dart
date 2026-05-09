import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';

class AnimatedChapterNavigation extends StatefulWidget {
  final bool isNext;
  final VoidCallback onTap;
  final bool visible;

  const AnimatedChapterNavigation({
    super.key,
    required this.isNext,
    required this.onTap,
    this.visible = true,
  });

  @override
  State<AnimatedChapterNavigation> createState() => _AnimatedChapterNavigationState();
}

class _AnimatedChapterNavigationState extends State<AnimatedChapterNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: widget.visible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !widget.visible,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(widget.isNext ? _animation.value : -_animation.value, 0),
                  child: AppHugeIcon(
                    icon: widget.isNext ? HugeIcons.strokeRoundedArrowRight01 : HugeIcons.strokeRoundedArrowLeft01,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 32,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
