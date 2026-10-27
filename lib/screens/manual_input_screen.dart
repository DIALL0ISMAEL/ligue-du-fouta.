import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'validation_result_screen.dart';

class ManualInputScreen extends StatefulWidget {
  final String? currentMatchId;
  const ManualInputScreen({super.key, this.currentMatchId});

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  final TextEditingController _codeController = TextEditingController(text: 'LF-2026-');
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _appendDigit(String digit) {
    if (_codeController.text.length < 15) {
      setState(() {
        _codeController.text += digit;
      });
    }
  }

  void _backspace() {
    if (_codeController.text.length > 8) {
      setState(() {
        _codeController.text =
            _codeController.text.substring(0, _codeController.text.length - 1);
      });
    }
  }

  void _clear() {
    setState(() {
      _codeController.text = 'LF-2026-';
    });
  }

  Future<void> _verifyCode(String code) async {
    final clean = code.trim();
    if (clean.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un code de billet complet')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await SupabaseService().validateTicket(
      ticketCode: clean,
      currentMatchId: widget.currentMatchId,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ValidationResultScreen(
          result: result,
          onScanNext: () {
            _clear();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Saisie Manuelle'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Entrez les chiffres du code billet',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Champ d'affichage du code
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGreen, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined, color: AppTheme.gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _codeController.text,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.backspace_outlined, color: AppTheme.textMuted),
                      onPressed: _backspace,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Raccourcis de test rapides
              Wrap(
                spacing: 8,
                children: [
                  _quickCodeChip('000001'),
                  _quickCodeChip('000002'),
                  _quickCodeChip('000003'),
                ],
              ),
              const Spacer(),

              // Pavé Numérique Rapide
              _buildKeypad(),
              const SizedBox(height: 16),

              // Bouton Valider
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _verifyCode(_codeController.text),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Vérifier le Billet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickCodeChip(String suffix) {
    return ActionChip(
      backgroundColor: AppTheme.cardSurface,
      side: const BorderSide(color: AppTheme.cardBorder),
      label: Text(
        'LF-2026-$suffix',
        style: const TextStyle(color: AppTheme.gold, fontSize: 12, fontFamily: 'monospace'),
      ),
      onPressed: () {
        setState(() {
          _codeController.text = 'LF-2026-$suffix';
        });
      },
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              return SizedBox(
                width: 80,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    if (key == 'C') {
                      _clear();
                    } else if (key == '⌫') {
                      _backspace();
                    } else {
                      _appendDigit(key);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.cardSurface,
                    side: const BorderSide(color: AppTheme.cardBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    key,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: (key == 'C' || key == '⌫') ? AppTheme.gold : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
