import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    this.error,
  });

  final String? error;

  @override
  Widget build(BuildContext context) {
    final details = error?.trim();
    final hasDetails = details != null && details.isNotEmpty;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF120F0B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF59E0B),
          secondary: Color(0xFFF97316),
          surface: Color(0xFF211A12),
        ),
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF120F0B),
                Color(0xFF2A1D12),
                Color(0xFF4A2B13),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xCC1A140F),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0x66F59E0B),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 32,
                        offset: Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0x22F59E0B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x55F59E0B)),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_motion_rounded,
                          size: 32,
                          color: Color(0xFFFCD34D),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'A inicializacao tropeçou.',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'A interface principal nao conseguiu abrir. Os detalhes tecnicos ficaram preservados para diagnostico, sem esconder o problema atras de uma tela vazia.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFFE7D7C3),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          const _StatusChip(
                            icon: Icons.warning_amber_rounded,
                            label: 'Falha na inicializacao',
                          ),
                          _StatusChip(
                            icon: Icons.bug_report_outlined,
                            label: hasDetails
                                ? 'Detalhes capturados'
                                : 'Sem stack trace disponivel',
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF15110D),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x33FFFFFF)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'O que verificar agora',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              '1. Confirme as configuracoes de Firebase e servicos locais.',
                              style: TextStyle(color: Color(0xFFD6C4AF)),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '2. Se estiver na web, atualize a pagina para repetir o fluxo de bootstrap.',
                              style: TextStyle(color: Color(0xFFD6C4AF)),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '3. Copie o erro abaixo e use no proximo diagnostico.',
                              style: TextStyle(color: Color(0xFFD6C4AF)),
                            ),
                          ],
                        ),
                      ),
                      if (hasDetails) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Relatorio tecnico',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: details),
                                );
                              },
                              icon: const Icon(Icons.content_copy_rounded),
                              label: const Text('Copiar erro'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFDE68A),
                                side: const BorderSide(
                                  color: Color(0x66F59E0B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 320),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F0C09),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0x33FFFFFF)),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              details,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: Color(0xFFF6E7D1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1AF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFDE68A)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFF8EBD8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
