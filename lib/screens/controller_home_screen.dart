import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'qr_scanner_screen.dart';
import 'manual_input_screen.dart';
import 'scan_history_screen.dart';
import 'profile_screen.dart';

class ControllerHomeScreen extends StatefulWidget {
  final String agentName;
  const ControllerHomeScreen({super.key, this.agentName = 'Agent Contrôleur'});

  @override
  State<ControllerHomeScreen> createState() => _ControllerHomeScreenState();
}

class _ControllerHomeScreenState extends State<ControllerHomeScreen> {
  List<MatchModel> _matches = [];
  MatchModel? _selectedMatch;
  bool _isLoading = true;

  int _countScanned = 142;
  int _countAccepted = 138;
  int _countRefused = 4;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    final list = await SupabaseService().fetchMatches();
    setState(() {
      _matches = list;
      if (list.isNotEmpty) {
        _selectedMatch = list.first;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Contrôle Ligue du Fouta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppTheme.gold),
            tooltip: 'Historique des Scans',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            tooltip: 'Profil Agent',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    agentName: widget.agentName,
                    role: 'Contrôleur de Stade',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMatches,
          color: AppTheme.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Carte Agent
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.security, color: AppTheme.primaryGreen, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.agentName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Poste de Contrôle Actif • Porte Principale',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Sélecteur de Match
                const Text(
                  'MATCH EN COURS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                            ),
                          ),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<MatchModel>(
                            isExpanded: true,
                            dropdownColor: AppTheme.cardSurface,
                            value: _selectedMatch,
                            items: _matches.map((m) {
                              return DropdownMenuItem<MatchModel>(
                                value: m,
                                child: Text(
                                  '${m.teamA} vs ${m.teamB}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedMatch = val);
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Statistiques Journalières
                Row(
                  children: [
                    _kpiCard('Scannés', '$_countScanned', Colors.white, Icons.qr_code_scanner),
                    const SizedBox(width: 10),
                    _kpiCard('Validés', '$_countAccepted', AppTheme.primaryGreen, Icons.check_circle_outline),
                    const SizedBox(width: 10),
                    _kpiCard('Refusés', '$_countRefused', AppTheme.alertRed, Icons.cancel_outlined),
                  ],
                ),
                const SizedBox(height: 32),

                // Gros Bouton Scanner
                SizedBox(
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QrScannerScreen(currentMatchId: _selectedMatch?.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner, size: 28, color: Colors.white),
                    label: const Text(
                      'SCANNER QR CODE',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Bouton Saisie Manuelle
                SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManualInputScreen(currentMatchId: _selectedMatch?.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.keyboard, color: AppTheme.gold),
                    label: const Text(
                      'Saisie Manuelle de Code',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppTheme.cardSurface,
                      side: const BorderSide(color: AppTheme.cardBorder, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
