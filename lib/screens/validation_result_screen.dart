import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ValidationResultScreen extends StatelessWidget {
  final ValidationResult result;
  final VoidCallback onScanNext;

  const ValidationResultScreen({
    super.key,
    required this.result,
    required this.onScanNext,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusTitle;

    switch (result.status) {
      case ValidationStatus.accepted:
        statusColor = AppTheme.primaryGreen;
        statusIcon = Icons.check_circle_rounded;
        statusTitle = 'ENTRÉE AUTORISÉE';
        break;
      case ValidationStatus.alreadyUsed:
        statusColor = AppTheme.alertRed;
        statusIcon = Icons.cancel_rounded;
        statusTitle = 'TICKET DÉJÀ UTILISÉ';
        break;
      case ValidationStatus.notFound:
      case ValidationStatus.wrongMatch:
        statusColor = AppTheme.orangeWarning;
        statusIcon = Icons.warning_rounded;
        statusTitle = result.status == ValidationStatus.wrongMatch
            ? 'MAUVAIS MATCH'
            : 'TICKET INTROUVABLE';
        break;
      case ValidationStatus.cancelled:
      case ValidationStatus.error:
        statusColor = AppTheme.greyCancelled;
        statusIcon = Icons.block_flipped;
        statusTitle = result.status == ValidationStatus.cancelled
            ? 'BILLET ANNULÉ'
            : 'ERREUR DE SCAN';
        break;
    }

    final formattedTime = result.scannedAt != null
        ? DateFormat('HH:mm:ss - dd/MM/yyyy').format(result.scannedAt!)
        : DateFormat('HH:mm:ss').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge de Statut Haut
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 84),
                    const SizedBox(height: 14),
                    Text(
                      statusTitle,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.message,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Détails du Ticket
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Code du ticket
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('CODE BILLET',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBorder,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            result.ticketCode,
                            style: const TextStyle(
                              color: AppTheme.gold,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppTheme.cardBorder, height: 28),

                    if (result.supporterName != null) ...[
                      _detailRow('Supporter', result.supporterName!),
                      const SizedBox(height: 12),
                    ],

                    if (result.zoneName != null) ...[
                      _detailRow('Tribune / Zone', result.zoneName!),
                      const SizedBox(height: 12),
                    ],

                    if (result.matchTitle != null) ...[
                      _detailRow('Rencontre', result.matchTitle!),
                      const SizedBox(height: 12),
                    ],

                    _detailRow('Horodatage', formattedTime),

                    if (result.firstScannedBy != null) ...[
                      const SizedBox(height: 12),
                      _detailRow('Agent 1er Scan', result.firstScannedBy!),
                    ],
                  ],
                ),
              ),

              // Bouton Recommencer le Scan
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onScanNext();
                  },
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text(
                    'Scanner le billet suivant',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(color: AppTheme.textLight, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
