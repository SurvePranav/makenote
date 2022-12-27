import 'auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<AuthUser> lonIn({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendVerificationLink();
}
