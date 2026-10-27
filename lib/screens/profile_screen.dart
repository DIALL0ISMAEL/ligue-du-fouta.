import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../config/supabase_config.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String agentName;
  final String role;

  const ProfileScreen({
    super.key,
    this.agentName = 'Agent Contrôleur',
    this.role = 'Contrôleur de Stade',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Profil & Paramètres'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cardSurface,
                  border: Border.all(color: AppTheme.primaryGreen, width: 2.5),
                ),
                child: const Center(
                  child: Icon(Icons.person, color: AppTheme.primaryGreen, size: 50),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                agentName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Sécurité & Supabase
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lock_outline, color: AppTheme.primaryGreen, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'SÉCURITÉ & CONNEXION SUPABASE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMuted,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _securityItem('Projet Supabase', 'ijvkzgnctnrpigoasbvr'),
                    const SizedBox(height: 10),
                    _securityItem('URL Passerelle', SupabaseConfig.url),
                    const SizedBox(height: 10),
                    _securityItem(
                      'Clé Client Mobile',
                      'Clé Publique Anon (Sécurisée)',
                      statusColor: AppTheme.primaryGreen,
                    ),
                    const SizedBox(height: 10),
                    _securityItem(
                      'Clé Service Role',
                      'Absente (Interdite en client)',
                      statusColor: AppTheme.primaryGreen,
                    ),
                    const SizedBox(height: 10),
                    _securityItem('Anti-Fraude Côté Serveur', 'PostgreSQL FOR UPDATE'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Bouton Déconnexion
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await SupabaseService().signOut();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.alertRed),
                  label: const Text(
                    'Se déconnecter',
                    style: TextStyle(color: AppTheme.alertRed, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.alertRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _securityItem(String label, String value, {Color? statusColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: statusColor ?? Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
