import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class MatchCreateScreen extends StatefulWidget {
  const MatchCreateScreen({super.key});

  @override
  State<MatchCreateScreen> createState() => _MatchCreateScreenState();
}

class _MatchCreateScreenState extends State<MatchCreateScreen> {
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _stadiumController = TextEditingController(text: 'Stade Régional de Labé');
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 16, minute: 30);
  bool _isLoading = false;

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _stadiumController.dispose();
    super.dispose();
  }

  Future<void> _submitMatch() async {
    final teamA = _teamAController.text.trim();
    final teamB = _teamBController.text.trim();
    final stadium = _stadiumController.text.trim();

    if (teamA.isEmpty || teamB.isEmpty || stadium.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final matchDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final success = await SupabaseService().createMatch(
      teamA: teamA,
      teamB: teamB,
      stadium: stadium,
      date: matchDateTime,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.primaryGreen,
          content: Text('Rencontre créée avec succès sur Supabase'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.alertRed,
          content: Text('Erreur lors de la création du match'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMMM yyyy', 'fr_FR').format(_selectedDate);
    final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Nouvelle Rencontre'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _teamAController,
                decoration: const InputDecoration(
                  labelText: 'Équipe Domicile (A)',
                  prefixIcon: Icon(Icons.shield, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _teamBController,
                decoration: const InputDecoration(
                  labelText: 'Équipe Extérieure (B)',
                  prefixIcon: Icon(Icons.shield_outlined, color: AppTheme.gold),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _stadiumController,
                decoration: const InputDecoration(
                  labelText: 'Stade / Lieu',
                  prefixIcon: Icon(Icons.stadium, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 20),

              // Date et Heure
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      icon: const Icon(Icons.calendar_today, color: AppTheme.gold, size: 18),
                      label: Text(dateStr, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.cardBorder),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null) setState(() => _selectedTime = picked);
                      },
                      icon: const Icon(Icons.access_time, color: AppTheme.primaryGreen, size: 18),
                      label: Text(timeStr, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.cardBorder),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitMatch,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enregistrer le Match'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
