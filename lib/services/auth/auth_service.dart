import 'auth_provider.dart';
import 'auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  AuthService(this.provider);

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(email: email, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<AuthUser> lonIn({required String email, required String password}) =>
      provider.lonIn(email: email, password: password);

  @override
  Future<void> sendVerificationLink() => provider.sendVerificationLink();
}
