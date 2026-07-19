import 'package:flutter/material.dart';

class DeepUnderstandingDialog extends StatefulWidget {
  final TextEditingController queryController;

  const DeepUnderstandingDialog({
    super.key,
    required this.queryController,
  });

  @override
  State<DeepUnderstandingDialog> createState() =>
      _DeepUnderstandingDialogState();

  static Future<String?> show(BuildContext context) {
    final TextEditingController queryController = TextEditingController();
    return showDialog<String?>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) =>
          DeepUnderstandingDialog(queryController: queryController),
    );
  }
}

class _DeepUnderstandingDialogState extends State<DeepUnderstandingDialog> {
  String _selectedTab = 'Contexto';

  @override
  Widget build(BuildContext context) {
    // responsive design: adjust dialog width based on screen size
    final double screenWidth = MediaQuery.of(context).size.width;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth < 600 ? screenWidth * 0.9 : 500,
      ),
      child: SingleChildScrollView(
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Main Dialog Card
              Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: const Color(
                      0xFFFCFAF2), // Cozy cream/parchment background
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1E2732), // Dark hand-drawn outline
                    width: 1.8,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Color(
                          0x337AA2B8), // Soft blue glow shadow from the image
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Row
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 20, left: 20, right: 20, bottom: 16),
                        child: Text(
                          'Análise de versículo e contexto',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2732),
                            fontFamily: 'TASAOrbiter',
                          ),
                        ),
                      ),
                    ),

                    // Custom Tabs (Contexto, Palavras-Chave, Teologia, Histórico)
                    Row(
                      children: [
                        _buildTab('Contexto', _selectedTab == 'Contexto',
                            isFirst: true),
                        _buildTab(
                            'Palavras-Chave', _selectedTab == 'Palavras-Chave'),
                        _buildTab('Teologia', _selectedTab == 'Teologia'),
                        _buildTab('Histórico', _selectedTab == 'Histórico',
                            isLast: true),
                      ],
                    ),

                    // Content area
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Input Text Field with Sketch Border
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF1E2732), // Dark outline
                                width: 1.8,
                              ),
                            ),
                            child: TextField(
                              controller: widget.queryController,
                              maxLines: 3,
                              autofocus: true,
                              cursorColor: const Color(0xFF1E2732),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF1E2732),
                                fontFamily: 'TASAOrbiter',
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'Digite sua dúvida ou tema...\n(ex: Injustiça)',
                                hintStyle: TextStyle(
                                  color: Color(0xFF7A8D99),
                                  fontSize: 14,
                                  height: 1.4,
                                  fontFamily: 'TASAOrbiter',
                                ),
                                fillColor: Colors.transparent,
                                filled: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Action Buttons (Cancelar, Gerar Análise)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context, null),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFCFAF2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF1E2732),
                                        width: 1.8,
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancelar',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E2732),
                                        fontFamily: 'TASAOrbiter',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    final query =
                                        widget.queryController.text.trim();
                                    final String result = query.isEmpty
                                        ? '$_selectedTab Entendimento geral'
                                        : '$_selectedTab: $query';
                                    Navigator.pop(context, result);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                          0xFF708E9E), // Slate blue-grey button
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF1E2732),
                                        width: 1.8,
                                      ),
                                    ),
                                    child: const Text(
                                      'Gerar Análise',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E2732),
                                        fontFamily: 'TASAOrbiter',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Caret pointing down at the top center
              Positioned(
                top: 4,
                child: RotationTransition(
                  turns: const AlwaysStoppedAnimation(45 / 360),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCFAF2),
                      border: Border(
                        bottom:
                            BorderSide(color: Color(0xFF1E2732), width: 1.8),
                        right: BorderSide(color: Color(0xFF1E2732), width: 1.8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected,
      {bool isFirst = false, bool isLast = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFFCFAF2) : const Color(0xFFD3E0EA),
            border: Border(
              top: const BorderSide(color: Color(0xFF1E2732), width: 1.5),
              bottom: BorderSide(
                color: const Color(0xFF1E2732),
                width: isSelected
                    ? 3.0
                    : 1.5, // Extra thick underline for active tab
              ),
              left: isFirst
                  ? BorderSide.none
                  : const BorderSide(color: Color(0xFF1E2732), width: 1.5),
              right: isLast
                  ? BorderSide.none
                  : const BorderSide(color: Color(0xFF1E2732), width: 1.5),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? const Color(0xFF1E2732)
                  : const Color(0xFF5A6E7F),
              fontFamily: 'TASAOrbiter',
            ),
          ),
        ),
      ),
    );
  }
}
