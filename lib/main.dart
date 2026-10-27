import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verrouillage de l'orientation en mode portrait pour un confort optimal en scan de stade
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialisation de la connexion Supabase avec cle publique (anon)
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Erreur lors de l\'initialisation Supabase: $e');
  }

  runApp(const LigueDuFoutaApp());
}

class LigueDuFoutaApp extends StatelessWidget {
  const LigueDuFoutaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ligue du Fouta - Contrôle Billets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
