import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'match_create_screen.dart';
import 'ticket_management_screen.dart';
import 'statistics_screen.dart';
import 'controller_home_screen.dart';
import 'profile_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Administration Ligue du Fouta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(
                    agentName: 'Directeur de Sécurité',
                    role: 'Administrateur Général',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bannière Admin
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.cardSurface],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield, color: AppTheme.gold, size: 30),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Supervision Centrale',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gestion des rencontres & anti-fraude Supabase',
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Titre KPIs
              const Text(
                'TABLEAU DE BORD EN TEMPS RÉEL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),

              // Grille KPIs
              Row(
                children: [
                  _kpiTile('Billets Émis', '2 500', AppTheme.gold, Icons.confirmation_number),
                  const SizedBox(width: 12),
                  _kpiTile('Entrées Validées', '1 842', AppTheme.primaryGreen, Icons.how_to_reg),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _kpiTile('Billets Restants', '658', Colors.white, Icons.timelapse),
                  const SizedBox(width: 12),
                  _kpiTile('Doublons Rejetés', '14', AppTheme.alertRed, Icons.gpp_bad),
                ],
              ),
              const SizedBox(height: 28),

              // Actions Admin
              const Text(
                'MODULES DE GESTION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),

              _adminActionCard(
                context,
                title: 'Créer une Nouvelle Rencontre',
                subtitle: 'Définir les équipes, stade, date et tribunes',
                icon: Icons.add_circle_outline,
                color: AppTheme.primaryGreen,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MatchCreateScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _adminActionCard(
                context,
                title: 'Gestion des Billets & QR Codes',
                subtitle: 'Recherche, annulation, génération et export',
                icon: Icons.qr_code_2,
                color: AppTheme.gold,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TicketManagementScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _adminActionCard(
                context,
                title: 'Statistiques & Rapports d\'Affluence',
                subtitle: 'Courbes de remplissage, cadence horaire',
                icon: Icons.bar_chart,
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _adminActionCard(
                context,
                title: 'Basculer en Mode Scanner Contrôleur',
                subtitle: 'Tester le scan directement sur le terrain',
                icon: Icons.camera_alt_outlined,
                color: AppTheme.textMuted,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ControllerHomeScreen(agentName: 'Superviseur'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiTile(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
