import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SplashLoader extends StatefulWidget {
  final IDatabaseLoader loader;
  final Widget child;

  const SplashLoader({
    super.key,
    required this.loader,
    required this.child,
  });

  @override
  State<SplashLoader> createState() => _SplashLoaderState();
}

class _SplashLoaderState extends State<SplashLoader> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await widget.loader.initialize();
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return widget.child;
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppHugeIcon(icon: HugeIcons.strokeRoundedAlert01, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar a Bíblia',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _error = null;
                    });
                    _init();
                  },
                  icon: const AppHugeIcon(icon: HugeIcons.strokeRoundedRefresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: StreamBuilder<WebDatabaseStatus>(
        stream: widget.loader.status,
        builder: (context, snapshot) {
          final status = snapshot.data;
          final type = status?.type ?? WebDatabaseStatusType.initializing;
          final progress = status?.progress ?? 0.0;

          String message = 'Iniciando...';
          switch (type) {
            case WebDatabaseStatusType.downloading:
              message = 'Baixando pacote da biblioteca bíblica...';
              break;
            case WebDatabaseStatusType.extracting:
              message = 'Preparando banco de dados...';
              break;
            case WebDatabaseStatusType.ready:
              message = 'Tudo pronto!';
              break;
            case WebDatabaseStatusType.error:
              message = 'Erro no carregamento';
              break;
            case WebDatabaseStatusType.initializing:
              message = 'Inicializando...';
              break;
          }

          return Stack(
            children: [
              // Centered app icon
              const Center(
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Image(
                    image: AssetImage('assets/icon/icon.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Bottom progress area
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF8A8A8A),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      widthFactor: progress.clamp(0.0, 1.0),
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A9EFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
