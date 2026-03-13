import 'package:flutter/material.dart';

class DeepUnderstandingHeroBanner extends StatelessWidget {
  final String query;
  final String teaser;
  final bool isDark;

  const DeepUnderstandingHeroBanner({
    super.key,
    required this.query,
    required this.teaser,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.surfaceContainer
                        ]
                      : [const Color(0xFF4A2B1D), const Color(0xFF3B5E53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Opacity(
                opacity: 0.12,
                child: GridView.count(
                  crossAxisCount: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    200,
                    (i) => const Text('✦',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ESTUDO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: isDark
                                ? Theme.of(context).colorScheme.primary
                                : const Color(0xFFD4A96A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '✦',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? Theme.of(context).colorScheme.primary
                                : const Color(0xFFD4A96A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(query.isEmpty ? 'Entendimento Aprofundado' : query)}.',
                      textAlign: TextAlign.left,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 26,
                        fontFamily: 'Georgia',
                        color: isDark
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
