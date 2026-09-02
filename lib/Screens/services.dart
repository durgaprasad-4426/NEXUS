import 'package:flutter_dotenv/flutter_dotenv.dart';

class Secrets {
  static String get apiKey =>
      dotenv.env['PI_KEY'] ??
      dotenv.env['GEMINI_API_KEY'] ??
      '';

  static const supabaseUrl = 'https://qdrlmwjekluahjkppuah.supabase.co';
  static const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFkcmxtd2pla2x1YWhqa3BwdWFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2NzY5MjYsImV4cCI6MjA3NTI1MjkyNn0.lzQTcqqU5SHk28jMt4lGQTatUpIocyFHmdPw0dVrLas';
  static const bucketName = 'user_profile_imgs';
}
