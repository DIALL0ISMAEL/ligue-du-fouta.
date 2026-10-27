/// Configuration de connexion Supabase pour Ligue du Fouta
/// STRICTEMENT limite a la cle publique (anon) pour la securite mobile.
class SupabaseConfig {
  static const String url = 'https://ijvkzgnctnrpigoasbvr.supabase.co';
  
  // Cle publique (anon) - Role: anon
  // Jamais de cle service_role sur le client mobile !
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlqdmt6Z25jdG5ycGlnb2FzYnZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI0MDUzODAsImV4cCI6MjEwNzk4MTM4MH0.5VKn98VPRIr8TujC7Pr1ciihj2L9H7OHdv2XItiEbKI';
}
