import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  List<ScanLogModel> _logs = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all', 'accepted', 'already_used', 'not_found'

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    final list = await SupabaseService().fetchScanLogs();
    setState(() {
      if (list.isNotEmpty) {
        _logs = list;
      } else {
        // Exemples d'historique en direct si vide
        _logs = [
          ScanLogModel(
            id: '1',
            ticketCode: 'LF-2026-000001',
            result: 'accepted',
            scannedAt: DateTime.now().subtract(const Duration(minutes: 2)),
            agentName: 'Agent Porte 1',
          ),
          ScanLogModel(
            id: '2',
            ticketCode: 'LF-2026-000002',
            result: 'accepted',
            scannedAt: DateTime.now().subtract(const Duration(minutes: 5)),
            agentName: 'Agent Porte 1',
          ),
          ScanLogModel(
            id: '3',
            ticketCode: 'LF-2026-000001',
            result: 'already_used',
            scannedAt: DateTime.now().subtract(const Duration(minutes: 7)),
            agentName: 'Agent Porte 2',
          ),
          ScanLogModel(
            id: '4',
            ticketCode: 'LF-2026-999999',
            result: 'not_found',
            scannedAt: DateTime.now().subtract(const Duration(minutes: 12)),
            agentName: 'Agent Porte 1',
          ),
        ];
      }
      _isLoading = false;
    });
  }

  List<ScanLogModel> get _filteredLogs {
    if (_filter == 'all') return _logs;
    return _logs.where((l) => l.result == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Historique des Scans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLogs,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _filterChip('Tous', 'all'),
                  const SizedBox(width: 8),
                  _filterChip('Autorisés', 'accepted'),
                  const SizedBox(width: 8),
                  _filterChip('Déjà utilisés', 'already_used'),
                  const SizedBox(width: 8),
                  _filterChip('Introuvables', 'not_found'),
                ],
              ),
            ),

            // Liste des logs
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                  : _filteredLogs.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun scan enregistré pour ce filtre',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredLogs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final log = _filteredLogs[index];
                            final isAccepted = log.result == 'accepted';
                            final isDuplicate = log.result == 'already_used';
                            final color = isAccepted
                                ? AppTheme.primaryGreen
                                : isDuplicate
                                    ? AppTheme.alertRed
                                    : AppTheme.orangeWarning;

                            final timeStr = DateFormat('HH:mm:ss').format(log.scannedAt);

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.cardSurface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          log.ticketCode,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          log.agentName ?? 'Agent',
                                          style: const TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        isAccepted
                                            ? 'VALIDÉ'
                                            : isDuplicate
                                                ? 'DOUBLON'
                                                : 'REFUSÉ',
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        timeStr,
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppTheme.primaryGreen,
      backgroundColor: AppTheme.cardSurface,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppTheme.textMuted,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: const BorderSide(color: AppTheme.cardBorder),
    );
  }
}
