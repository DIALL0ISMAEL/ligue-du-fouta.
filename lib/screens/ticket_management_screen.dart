import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'ticket_detail_screen.dart';

class TicketManagementScreen extends StatefulWidget {
  const TicketManagementScreen({super.key});

  @override
  State<TicketManagementScreen> createState() => _TicketManagementScreenState();
}

class _TicketManagementScreenState extends State<TicketManagementScreen> {
  List<TicketModel> _tickets = [];
  bool _isLoading = true;
  String _filter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    final list = await SupabaseService().fetchTickets();
    setState(() {
      if (list.isNotEmpty) {
        _tickets = list;
      } else {
        // Exemples réalistes
        _tickets = List.generate(
          12,
          (i) => TicketModel(
            id: 'ticket-$i',
            matchId: 'match-1',
            ticketCode: 'LF-2026-${(i + 1).toString().padLeft(6, '0')}',
            supporterName: 'Supporter Officiel #${i + 1}',
            status: i % 3 == 0 ? 'used' : (i == 7 ? 'cancelled' : 'valid'),
          ),
        );
      }
      _isLoading = false;
    });
  }

  List<TicketModel> get _filteredTickets {
    return _tickets.where((t) {
      final matchesFilter = _filter == 'all' || t.status == _filter;
      final matchesSearch = _searchQuery.isEmpty ||
          t.ticketCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.supporterName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Gestion des Billets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTickets,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de Recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Rechercher un code (ex: LF-2026-...) ou nom',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                  isDense: true,
                ),
              ),
            ),

            // Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _filterChip('Tous', 'all'),
                  const SizedBox(width: 8),
                  _filterChip('Valides', 'valid'),
                  const SizedBox(width: 8),
                  _filterChip('Utilisés', 'used'),
                  const SizedBox(width: 8),
                  _filterChip('Annulés', 'cancelled'),
                ],
              ),
            ),

            // Liste des Billets
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                  : _filteredTickets.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun billet trouvé',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTickets.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final ticket = _filteredTickets[index];
                            final isValid = ticket.status == 'valid';
                            final isUsed = ticket.status == 'used';
                            final color = isValid
                                ? AppTheme.primaryGreen
                                : isUsed
                                    ? AppTheme.alertRed
                                    : AppTheme.greyCancelled;

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TicketDetailScreen(ticket: ticket),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardSurface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.qr_code, color: color, size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ticket.ticketCode,
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            ticket.supporterName,
                                            style: const TextStyle(
                                              color: AppTheme.textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isValid ? 'VALIDE' : isUsed ? 'UTILISÉ' : 'ANNULÉ',
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                                  ],
                                ),
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
