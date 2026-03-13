import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../viewmodels/about_viewmodel.dart';

class AboutView extends StackedView<AboutViewModel> {
  const AboutView({super.key});

  @override
  Widget builder(
    BuildContext context,
    AboutViewModel viewModel,
    Widget? child,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Adaptive colors based on Material 3 Theme
    final surfaceColor = isDark
        ? theme.colorScheme.surfaceContainerLow
        : theme.colorScheme.surfaceContainerHigh;

    final accentColor = theme.colorScheme.primary;
    const whatsappGreen = Color(0xFF22C55E);

    // Community card background - keep brand colors but adjust for light mode
    final communityCardBg = isDark
        ? const Color(0xFF312E81)
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.9);

    final communityTextColor =
        isDark ? Colors.white : theme.colorScheme.onPrimaryContainer;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('App de Estudo Bíblico'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(context),
                  const SizedBox(height: 24),

                  // 3. Testimonials Carousel
                  _buildTestimonialsCarousel(
                      context, viewModel, surfaceColor, accentColor),
                  const SizedBox(height: 32),

                  // 1. Features Section
                  _buildFeaturesSection(
                      context, viewModel, surfaceColor, accentColor),
                  const SizedBox(height: 32),

                  // 2. FAQ Section
                  _buildFAQSection(
                      context, viewModel, surfaceColor, accentColor),
                  const SizedBox(height: 32),

                  _buildFooter(context, viewModel),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image:
              AssetImage('assets/images/backgrounds/pexels-pixabay-69389.jpg'),
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descubra o poder da Palavra de Deus',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '”Se somos filhos, então, também somos herdeiros; herdeiros de Deus e co-herdeiros com Cristo..” - Romanos 8:17',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    AboutViewModel viewModel,
    Color surfaceColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.groups_rounded, color: accentColor, size: 32),
          const SizedBox(height: 12),
          Text(
            'IRMÃOS CONECTADOS',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.connectedBrothers,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.north_east_rounded,
                  size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 4),
              Text(
                viewModel.growthThisMonth,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    AboutViewModel viewModel,
    Color surfaceColor,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'FUNCIONALIDADES',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ),
        ...viewModel.features.map((feature) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.3)),
              ),
              child: ListTile(
                leading: Icon(feature['icon'] as IconData, color: accentColor),
                title: Text(feature['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(feature['description'] as String,
                    style: const TextStyle(fontSize: 13)),
              ),
            )),
      ],
    );
  }

  Widget _buildFAQSection(
    BuildContext context,
    AboutViewModel viewModel,
    Color surfaceColor,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'PERGUNTAS FREQUENTES',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.3)),
          ),
          child: Column(
            children: viewModel.faq
                .map((item) => ExpansionTile(
                      title: Text(item['question']!,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      shape: const Border(),
                      collapsedShape: const Border(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(item['answer']!,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7))),
                        )
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialsCarousel(
    BuildContext context,
    AboutViewModel viewModel,
    Color surfaceColor,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'O QUE DIZEM NOSSOS USUÁRIOS',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ),
        _CarouselWidget(
          testimonials: viewModel.testimonials,
          currentIndex: viewModel.currentTestimonialIndex,
          onPageChanged: viewModel.setTestimonialIndex,
          surfaceColor: surfaceColor,
          accentColor: accentColor,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, AboutViewModel viewModel) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FooterButton(
                label: 'TERMOS DE USO', onTap: viewModel.openTermsOfUse),
            _buildDot(),
            _FooterButton(
                label: 'PRIVACIDADE', onTap: viewModel.openPrivacyPolicy),
            _buildDot(),
            _FooterButton(label: 'SUPORTE', onTap: viewModel.openSupport),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Versão ${viewModel.version} + © 2026 ${viewModel.appName}',
          style: TextStyle(
            fontSize: 11,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text('•',
          style: TextStyle(color: Colors.grey.withValues(alpha: 0.5))),
    );
  }

  @override
  AboutViewModel viewModelBuilder(BuildContext context) => AboutViewModel();

  @override
  void onViewModelReady(AboutViewModel viewModel) => viewModel.init();
}

class _CarouselWidget extends StatefulWidget {
  final List<Map<String, String>> testimonials;
  final int currentIndex;
  final Function(int) onPageChanged;
  final Color surfaceColor;
  final Color accentColor;

  const _CarouselWidget({
    required this.testimonials,
    required this.currentIndex,
    required this.onPageChanged,
    required this.surfaceColor,
    required this.accentColor,
  });

  @override
  State<_CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<_CarouselWidget> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  void didUpdateWidget(_CarouselWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _pageController.animateToPage(
        widget.currentIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: widget.onPageChanged,
            itemCount: widget.testimonials.length,
            itemBuilder: (context, index) {
              final item = widget.testimonials[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote_rounded,
                        color: widget.accentColor, size: 32),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        item['text']!,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(Icons.person,
                              size: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['author']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              item['role']!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.testimonials.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.currentIndex == index
                    ? widget.accentColor
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
