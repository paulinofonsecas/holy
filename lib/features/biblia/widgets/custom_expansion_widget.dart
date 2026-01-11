import 'package:flutter/material.dart';

class CustomExpansionWidget extends StatefulWidget {
  const CustomExpansionWidget({
    super.key,
    required this.headerBuilder,
    required this.child,
    this.initiallyExpanded = false,
    this.headerPadding = EdgeInsets.zero,
    this.contentPadding = EdgeInsets.zero,
    this.decoration,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.onExpansionChanged,
    this.enableFeedback = true,
  });

  final Widget Function(BuildContext context, bool isExpanded) headerBuilder;
  final Widget child;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry contentPadding;
  final Decoration? decoration;
  final Duration duration;
  final Curve curve;
  final ValueChanged<bool>? onExpansionChanged;
  final bool enableFeedback;

  @override
  State<CustomExpansionWidget> createState() => _CustomExpansionWidgetState();
}

class _CustomExpansionWidgetState extends State<CustomExpansionWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(CustomExpansionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyExpanded != oldWidget.initiallyExpanded) {
      _isExpanded = widget.initiallyExpanded;
    }
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpansion,
            enableFeedback: widget.enableFeedback,
            child: Padding(
              padding: widget.headerPadding,
              child: widget.headerBuilder(context, _isExpanded),
            ),
          ),
        ),
        if (_isExpanded)
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topLeft,
              duration: widget.duration,
              curve: widget.curve,
              heightFactor: _isExpanded ? 1 : 0,
              child: Padding(
                padding: widget.contentPadding,
                child: widget.child,
              ),
            ),
          ),
      ],
    );

    if (widget.decoration == null) {
      return column;
    }

    return Container(
      decoration: widget.decoration,
      child: column,
    );
  }
}
