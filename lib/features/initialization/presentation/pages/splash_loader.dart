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
      body: StreamBuilder<WebDatabaseStatus>(
        stream: widget.loader.status,
        builder: (context, snapshot) {
          final status = snapshot.data;
          final type = status?.type ?? WebDatabaseStatusType.initializing;
          final progress = status?.progress ?? 0.0;

          String message = 'Iniciando...';
          switch (type) {
            case WebDatabaseStatusType.downloading:
              message = 'Baixando biblioteca...';
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

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppHugeIcon(
                    icon: HugeIcons.strokeRoundedBook01,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 12,
                        width:
                            MediaQuery.of(context).size.width * 0.8 * progress,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.blueAccent],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
