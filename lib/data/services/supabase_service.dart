import 'package:repx/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) {
    return supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signup(String email, String password) {
    return supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() {
    return supabase.auth.signOut();
  }

  Future<User?> get currentUser async {
    final session = supabase.auth.currentSession;
    return session?.user;
  }

  Future<void> createUser(UserModel user) async {
    // Implement user creation logic if needed
    print('id: ${user.id}, email: ${user.email}, username: ${user.username},');
    await supabase.from('users').insert([
      {
        'email': user.email,
        'username': user.username,
        'gender': user.gender,
        'id': user.id,
      },
    ]);
  }
}
