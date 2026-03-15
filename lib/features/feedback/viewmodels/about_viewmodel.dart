import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutViewModel extends BaseViewModel {
  String _appName = '';
  String get appName => _appName;

  String _version = '';
  String get version => _version;

  String _buildNumber = '';
  String get buildNumber => _buildNumber;

  // Mocked data for the new design
  final String connectedBrothers = '+54.280';
  final String growthThisMonth = '12% este mês';

  // App Features
  final List<Map<String, dynamic>> features = [
    {
      'title': 'Biblia Interativa',
      'description':
          'Explore a Bíblia de forma dinâmica com notas, marcações e planos de leitura personalizados.',
      'icon': Icons.menu_book_rounded,
    },
    {
      'title': 'Multiplas Versões',
      'description':
          'Acesse diversas traduções da Bíblia para enriquecer seu estudo e compreensão.',
      'icon': Icons.compare_arrows_rounded,
    },
    {
      'title': 'Estudo Profundo',
      'description':
          'Ferramentas avançadas de análise e comparação de versículos.',
      'icon': Icons.analytics_outlined,
    },
    {
      'title': 'Comunidade Ativa',
      'description': 'Compartilhe reflexões e cresça junto com outros irmãos.',
      'icon': Icons.people_outline_rounded,
    },
    {
      'title': 'Versículos Diários',
      'description': 'Receba inspiração diária diretamente no seu dispositivo.',
      'icon': Icons.wb_sunny_outlined,
    },
    // {
    //   'title': 'Sincronização Cloud',
    //   'description': 'Suas notas e marcações acessíveis em qualquer lugar.',
    //   'icon': Icons.cloud_done_outlined,
    // },
  ];

  // Growth Mission Text
  final String growthTitle = 'Cresça com a Bíblia Interativa';
  final String growthIntro =
      'Entender seu papel no Reino de Deus exige estudo consistênte e profundo. Nosso aplicativo une o estudo bíblico dinâmico à vida em comunidade para acelerar seu amadurecimento cristão:';
  final String growthIdentityTitle = 'Identidade na Palavra';
  final String growthIdentityBody =
      'Use as marcações e estudos personalizadas para registrar o que Deus fala especificamente ao seu coração.';
  final String growthUnityTitle = 'Vida em Unidade';
  final String growthUnityBody =
      'Transforme seu estudo em ação prática, conectando-se com os planos de leitura que mostram como servir melhor ao Corpo de Cristo.';
  final String growthFooter =
      'Sua jornada de autoconhecimento em Jesus começa aqui.';

  // FAQ Data
  final List<Map<String, String>> faq = [
    {
      'question': 'O aplicativo é gratuito?',
      'answer':
          'Sim, as funcionalidades principais são e sempre serão gratuitas para todos.',
    },
    {
      'question': 'Como participo dos grupos?',
      'answer':
          'Basta clicar no botão "Entrar no Grupo" nesta tela ou na aba Comunidade.',
    },
    {
      'question': 'Posso ler offline?',
      'answer':
          'Sim! Você pode baixar versões da Bíblia para ler sem necessidade de internet.',
    },
    {
      'question': 'Como funciona a Inteligência Artificial?',
      'answer':
          'A IA analisa o contexto dos versículos selecionados para oferecer insights teológicos e devocionais profundos.',
    },
    {
      'question': 'Posso mudar o tema do aplicativo?',
      'answer':
          'Sim! Vá para o seu perfil e selecione "Cores e Tema" para personalizar sua experiência com diversas cores e modos.',
    },
    {
      'question': 'Onde vejo meu histórico?',
      'answer':
          'Seu histórico de leitura e análises fica disponível na aba "Estudos" e também na seção de histórico do seu Perfil.',
    },
    {
      'question': 'Como faço para marcar um versículo?',
      'answer':
          'Basta tocar sobre o versículo que deseja. Um menu de ações aparecerá permitindo marcar, copiar ou analisar com IA.',
    },
  ];

  // Testimonials Carousel Data
  final List<Map<String, String>> testimonials = [
    {
      'text':
          '“Encontrei muito mais do que uma Bíblia digital. Encontrei uma comunidade que me motiva a ler a palavra todos os dias através dos planos de leitura em grupo.”',
      'author': 'Ricardo Santos',
      'role': 'Membro há 8 meses',
    },
    {
      'text':
          '“As ferramentas de estudo são incríveis! Finalmente consigo entender passagens complexas com as referências cruzadas.”',
      'author': 'Maria Oliveira',
      'role': 'Estudante de Teologia',
    },
    {
      'text':
          '“Uso todos os dias para minha devocional. A interface é limpa e não me distrai do que realmente importa: a Palavra.”',
      'author': 'João Pereira',
      'role': 'Pastor Local',
    },
  ];

  Timer? _carouselTimer;
  int _currentTestimonialIndex = 0;
  int get currentTestimonialIndex => _currentTestimonialIndex;

  void setTestimonialIndex(int index) {
    _currentTestimonialIndex = index;
    notifyListeners();
  }

  Future<void> init() async {
    setBusy(true);
    final packageInfo = await PackageInfo.fromPlatform();
    _appName = packageInfo.appName;
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;

    // Start carousel auto-play logic
    _startCarouselTimer();

    setBusy(false);
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _currentTestimonialIndex =
          (_currentTestimonialIndex + 1) % testimonials.length;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    super.dispose();
  }

  Future<void> launchUrlExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void openWhatsAppGroup() {
    launchUrlExternal('https://chat.whatsapp.com/your-group-id');
  }

  void openTermsOfUse() {
    launchUrlExternal(
        'https://github.com/paulinofonsecas/holy/blob/main/TERMS_OF_USE.md');
  }

  void openPrivacyPolicy() {
    launchUrlExternal(
        'https://github.com/paulinofonsecas/holy/blob/main/PRIVACY_POLICY.md');
  }

  void openSupport() {
    launchUrlExternal('https://github.com/paulinofonsecas/holy/issues');
  }
}
