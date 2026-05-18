import 'dart:convert';

/// Persisted user entity — stored in [SharedPreferences] as JSON.
///
/// [password] is intentionally stored as-is here for the mock implementation.
/// In production, never persist a plaintext password — use tokens (JWT / OAuth).
class UserModel {
  final String  email;
  final String? name;
  final bool    isEmailVerified;
  final bool    rememberMe;

  const UserModel({
    required this.email,
    this.name,
    this.isEmailVerified = false,
    this.rememberMe      = false,
  });

  UserModel copyWith({
    String? email,
    String? name,
    bool?   isEmailVerified,
    bool?   rememberMe,
  }) {
    return UserModel(
      email:           email           ?? this.email,
      name:            name            ?? this.name,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      rememberMe:      rememberMe      ?? this.rememberMe,
    );
  }

  // ── JSON serialisation (for SharedPreferences) ───────────────────────────

  Map<String, dynamic> toJson() => {
    'email':           email,
    'name':            name,
    'isEmailVerified': isEmailVerified,
    'rememberMe':      rememberMe,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
     email:           json['email'] as String? ?? (throw ArgumentError.notNull('email')),
    name:            json['name']            as String?,
    isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    rememberMe:      json['rememberMe']      as bool? ?? false,
  );

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String source) =>
      UserModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
}