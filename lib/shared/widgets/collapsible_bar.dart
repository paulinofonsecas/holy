import 'package:flutter/material.dart';

/// Barra que colapsa/expande para o hide-on-scroll imersivo.
/// Com [alignment] topCenter: barras do topo deslizam para cima;
/// em barras do fundo (em Column) o conteúdo acima cobre-as deslizando-as
/// para baixo. O colapso é por clipping + fade, sem jank.
class CollapsibleBar extends StatelessWidget {
  const CollapsibleBar({
    super.key,
    required this.visible,
    this.alignment = Alignment.topCenter,
    required this.child,
  });

  final bool visible;
  final AlignmentGeometry alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedAlign(
        alignment: alignment,
        heightFactor: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: child,
        ),
      ),
    );
  }
}
