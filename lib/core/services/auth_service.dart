import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playon/core/models/user_model.dart';

class AuthService {
  AuthService._();

  static final _client = Supabase.instance.client;

  // ── Current user ──────────────────────────────────────────────────────────

  /// The currently logged-in Supabase [User], or `null`.
  static User? get supabaseUser => _client.auth.currentUser;

  /// Whether a user session currently exists.
  static bool get isLoggedIn => supabaseUser != null;

  /// Build a [UserModel] from the active Supabase session.
  /// Returns `null` if no session exists.
  static UserModel? get currentUser {
    final u = supabaseUser;
    if (u == null) return null;
    return UserModel.fromSupabaseUser(u);
  }

  // ── Session restore ───────────────────────────────────────────────────────

  /// Check if Supabase already has a valid persisted session.
  /// (Supabase SDK restores it automatically on init — this just reads it.)
  static Future<UserModel?> tryRestoreSession() async {
    // Refresh the session token if it has expired
    try {
      await _client.auth.refreshSession();
    } catch (_) {
      // No session or refresh failed — expected if not logged in
    }
    return currentUser;
  }

  // ── Sign in ───────────────────────────────────────────────────────────────

  /// Sign in with [email] and [password].
  /// Returns [UserModel] on success, throws [AuthException] on failure.
  static Future<UserModel> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final u = response.user;
    if (u == null) throw const AuthException('Sign in failed — no user returned.');
    return UserModel.fromSupabaseUser(u);
  }

  // ── Sign up ───────────────────────────────────────────────────────────────

  /// Create a new account with [email], [password], optional [displayName],
  /// and any extra [metadata] to store in the user's Supabase profile.
  /// Returns [UserModel] on success, throws [AuthException] on failure.
  static Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
    Map<String, dynamic>? metadata,
  }) async {
    final data = <String, dynamic>{};
    if (displayName != null && displayName.isNotEmpty) {
      data['full_name'] = displayName.trim();
    }
    if (metadata != null) data.addAll(metadata);

    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: data.isNotEmpty ? data : null,
    );
    final u = response.user;
    if (u == null) throw const AuthException('Sign up failed — no user returned.');

    // Attempt to store in 'users' table (ignoring errors if table doesn't exist yet, to not block auth)
    try {
      await _client.from('users').upsert({
        'id': u.id,
        'email': email.trim(),
        'full_name': displayName?.trim() ?? '',
        ...data,
      });
    } catch (_) {
      // Table might not be set up yet or RLS policies might block it, 
      // but the Auth user is created so we proceed.
    }

    return UserModel.fromSupabaseUser(u);
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  /// Sign out the current user.
  static Future<void> logout() async {
    await _client.auth.signOut();
  }
}
