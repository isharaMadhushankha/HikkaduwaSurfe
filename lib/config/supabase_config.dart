import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://daahqoqvltzwtbqajjxg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRhYWhxb3F2bHR6d3RicWFqanhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5OTgwMjEsImV4cCI6MjA5MTU3NDAyMX0.NAaLE8xAhJNQmeeRimRpc2Hr_l47YSG0jSic1DS-X5Y';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
}
