class User {
  final String id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final List<String> roles;

  User({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phone_number'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User? user;
  final bool isNewUser;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user,
    required this.isNewUser,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      isNewUser: json['is_new_user'] ?? false,
    );
  }
}
