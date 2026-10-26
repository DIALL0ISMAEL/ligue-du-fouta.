# ⚽ Ligue du Fouta – Contrôle des Tickets
## Dossier Technique & Guide Complet de Remise au Développeur

> **Projet :** Application mobile & web de contrôle des accès aux stades (Flutter + Supabase)  
> **Organisation :** Ligue du Fouta (Compétitions Officielles de Football)  
> **Date de livraison :** Octobre 2026  
> **Statut :** Prêt pour développement Flutter & Déployé sur Supabase

---

## 1. 🎯 Objectif & Périmètre du Système

L'application permet aux agents de sécurité et contrôleurs de la **Ligue du Fouta** de valider l'entrée des supporters lors des matchs en scannant le QR code d'un billet ou en saisissant son code unique (`LF-2026-XXXXXX`).

### Exigences Critiques :
1. **Unicité stricte :** Un ticket ne peut être utilisé qu'une seule fois.
2. **Anti-Fraude Côté Serveur (Verrou Atomique) :** Aucun risque de double entrée si deux agents scannent le même ticket à la même seconde grâce à un verrou PostgreSQL `SELECT ... FOR UPDATE` dans la fonction Supabase `validate_ticket`.
3. **Traçabilité totale :** Chaque tentative (validée, doublon, code introuvable, match incorrect ou annulé) est immédiatement enregistrée dans la table `scan_logs` avec l'agent, l'heure exacte et l'appareil.
4. **Tableau de bord Admin en temps réel :** Suivi de l'affluence, création des matchs, génération de tickets et export.

---

## 2. 👥 Rôles et Droits d'Accès

| Rôle | Périmètre d'action |
|---|---|
| **Administrateur (`admin`)** | Créer les matchs, définir les zones et tarifs, générer des séries de tickets, annuler/réinitialiser des tickets, voir toutes les statistiques et exporter les données. |
| **Contrôleur (`controller`)** | Scanner les QR codes, saisir manuellement les codes, valider ou refuser les entrées aux portes, consulter son historique de scan. |
| **Superviseur (`supervisor`)** | Consulter les statistiques en direct, gérer les litiges aux portes d'accès. |

---

## 3. 🗄️ Architecture Backend Supabase

### Projet Connecté :
- **Nom du projet :** `La Ligue du Fouta CI`
- **Project Ref :** `ijvkzgnctnrpigoasbvr`
- **URL API :** `https://ijvkzgnctnrpigoasbvr.supabase.co`
- **Clé Publique (Anon) :** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlqdmt6Z25jdG5ycGlnb2FzYnZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI0MDUzODAsImV4cCI6MjEwNzk4MTM4MH0.5VKn98VPRIr8TujC7Pr1ciihj2L9H7OHdv2XItiEbKI`

### Tables du Schéma :
1. **`profiles`** : Identifiants agents & admins (liés à `auth.users`), rôle (`admin`, `controller`), statut actif.
2. **`matches`** : Rencontres sportives (équipes, date/heure, stade, statut).
3. **`zones`** : Tribunes (VIP, Couverte, Populaire) avec prix et capacité.
4. **`tickets`** : Billets avec code unique `ticket_code` (`LF-2026-000123`), statut (`valid`, `used`, `cancelled`), horodatage et agent du scan.
5. **`scan_logs`** : Journal de tous les contrôles (`accepted`, `already_used`, `not_found`, `cancelled`, `wrong_match`).

---

## 4. 🔒 Logique Anti-Fraude Atomique (`validate_ticket`)

La vérification est exécutée **exclusivement côté serveur** via la fonction RPC PostgreSQL :

```sql
SELECT * FROM public.tickets WHERE ticket_code = v_code FOR UPDATE;
```

### Algorithme de Décision :
```text
1. L'agent transmet le code 'LF-2026-000123'
2. Le serveur pose un verrou exclusif sur la ligne du ticket
3. SI ticket inexistant :
      -> Log: 'not_found'
      -> Retour: Statut ORANGE ("Ticket introuvable")
4. SI match_id du ticket != match en cours :
      -> Log: 'wrong_match'
      -> Retour: Statut ORANGE ("Ticket pour un autre match")
5. SI ticket.status = 'cancelled' :
      -> Log: 'cancelled'
      -> Retour: Statut GRIS ("Ticket invalide ou annulé")
6. SI ticket.status = 'used' :
      -> Log: 'already_used'
      -> Retour: Statut ROUGE ("Ticket déjà utilisé" + Heure + Nom agent 1er scan)
7. SI ticket.status = 'valid' :
      -> UPDATE ticket SET status = 'used', scanned_at = NOW(), scanned_by = agent.id
      -> Log: 'accepted'
      -> Retour: Statut VERT ("Entrée autorisée" + Supporter + Zone + Match)
```

---

## 5. 📱 Répertoire des 13 Écrans de l'Application

| N° | Écran | Composants & Éléments Requis |
|---|---|---|
| **1** | **Splash Screen** | Logo officiel Ligue du Fouta, badge officiel, titre, bouton *Commencer*. |
| **2** | **Connexion** | Téléphone/Email, mot de passe, Auth Supabase, détection automatique du rôle (Admin / Contrôleur). |
| **3** | **Accueil Contrôleur** | Nom de l'agent, sélecteur de match, compteurs du jour (Scannés, Valides, Refusés), boutons *Scanner* & *Saisie manuelle*. |
| **4** | **Scanner QR Code** | Caméra plein écran avec `mobile_scanner`, cadre de visée animé, torche, validation automatique au décodage. |
| **5** | **Saisie Manuelle** | Champ `LF-2026-XXXXXX`, pavé numérique tactile rapide, raccourcis de test, bouton *Vérifier*. |
| **6** | **Résultat Validation** | 4 états visuels & sonores distincts :<br>• **Vert** : *Entrée autorisée* (Supporter, Zone, Match, Heure)<br>• **Rouge** : *Déjà utilisé* (Heure 1er scan, Agent)<br>• **Orange** : *Introuvable / Autre match*<br>• **Gris** : *Invalide / Annulé* |
| **7** | **Historique des Scans** | Liste filtrable (*Tous, Validés, Refusés, Déjà scannés, Introuvables*), recherche de code, horodatage. |
| **8** | **Accueil Administrateur** | KPIs en direct (*Total, Utilisés, Restants, Annulés*), boutons création match, gestion tickets, stats. |
| **9** | **Création de Match** | Formulaire : Nom, Équipe A, Équipe B, Stade, Date/Heure, définition des Zones avec prix et capacité. |
| **10** | **Gestion des Tickets** | Recherche, filtres de statut, générateur de tickets en lot (`ticket_code_seq`), export CSV/PDF. |
| **11** | **Détail du Ticket** | Rendu QR Code (SVG/Canvas), métadonnées, boutons *Partager*, *Annuler*, *Réinitialiser (Admin)*. |
| **12** | **Statistiques** | Graphique d'affluence par heure, jauge de taux de présence (%), répartition par zone, performance par agent. |
| **13** | **Profil** | Nom, rôle, téléphone, statut de sécurité, bascule démo, déconnexion. |

---

## 6. 🎨 Charte Graphique & Design System (Figma)

- **Vert Officiel Fouta :** `#008751` (Couleur primaire de validation, boutons principaux)
- **Jaune / Or :** `#FCD116` (Accents, zones VIP, trophées)
- **Rouge Alerte :** `#E8112D` (Refus, doublons, annulations)
- **Fond Sombre :** `#0A0F1D` (Mode sombre stade, contraste optimal sous le soleil)
- **Surfaces & Cartes :** `#131D31` (Cartes, bordure `#1E2C4A`)
- **Typographie :** Inter / Poppins / JetBrains Mono (pour les codes tickets).

---

## 7. 🚀 Structure du Code Flutter Livré

Le projet Flutter complet est structuré dans `/home/user/flutter_ligue_fouta/` :

```text
flutter_ligue_fouta/
├── pubspec.yaml                      # Dépendances Supabase, mobile_scanner, qr_flutter
├── lib/
│   ├── main.dart                     # Point d'entrée de l'application
│   ├── config/
│   │   └── supabase_config.dart      # URLs et clés API Supabase
│   ├── theme/
│   │   └── app_theme.dart            # Thème sombre officiel Ligue du Fouta
│   ├── models/
│   │   └── models.dart               # Modèles Match, Zone, Ticket, ScanLog, ValidationResult
│   ├── services/
│   │   └── supabase_service.dart     # Service d'authentification et RPC atomique
│   └── screens/
│       ├── splash_screen.dart        # Écran 1 : Splash
│       ├── login_screen.dart         # Écran 2 : Connexion
│       ├── controller_home_screen.dart # Écran 3 : Accueil Contrôleur
│       ├── qr_scanner_screen.dart    # Écran 4 : Scanner QR
│       ├── manual_input_screen.dart  # Écran 5 : Saisie Manuelle
│       ├── validation_result_screen.dart # Écran 6 : Résultat 4 statuts
│       ├── scan_history_screen.dart  # Écran 7 : Historique
│       ├── admin_home_screen.dart    # Écran 8 : Accueil Admin
│       ├── match_create_screen.dart  # Écran 9 : Création Match
│       ├── ticket_management_screen.dart # Écran 10 : Gestion Tickets
│       ├── ticket_detail_screen.dart # Écran 11 : Détail Ticket
│       ├── statistics_screen.dart    # Écran 12 : Statistiques
│       └── profile_screen.dart       # Écran 13 : Profil
```

---

## 8. 💻 Application Interactive de Test (Live Preview)

Une application web interactive connectée en direct au projet Supabase tourne sur le port `3000` dans le workspace.
Elle permet de tester immédiatement :
- Le scan de QR code via caméra ou boutons rapides
- La saisie manuelle de `LF-2026-000001` à `LF-2026-000010`
- La réaction sonore et visuelle pour chaque type de billet (valide, doublon, inconnu)
- Le tableau de bord administrateur et la génération de nouveaux billets.
