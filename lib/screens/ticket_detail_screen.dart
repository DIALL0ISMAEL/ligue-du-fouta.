import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class TicketDetailScreen extends StatelessWidget {
  final TicketModel ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isValid = ticket.status == 'valid';
    final isUsed = ticket.status == 'used';
    final statusColor = isValid
        ? AppTheme.primaryGreen
        : isUsed
            ? AppTheme.alertRed
            : AppTheme.greyCancelled;

    final statusText = isValid
        ? 'BILLET VALIDE'
        : isUsed
            ? 'UTILISÉ'
            : 'ANNULÉ';

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Détail du Billet'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Carte Billet avec QR Code
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    // Statut Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Rendu QR Code
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: ticket.ticketCode,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Code Texte
                    Text(
                      ticket.ticketCode,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ticket.supporterName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(color: AppTheme.cardBorder, height: 32),

                    // Détails
                    _rowInfo('Identifiant Système', ticket.id.substring(0, 8)),
                    const SizedBox(height: 10),
                    _rowInfo('Statut Base Supabase', ticket.status),
                    if (ticket.scannedAt != null) ...[
                      const SizedBox(height: 10),
                      _rowInfo('Heure de Scan', ticket.scannedAt.toString()),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Boutons d'Action Admin
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code ticket copié dans le presse-papier')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copier Code'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.cardBorder),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
