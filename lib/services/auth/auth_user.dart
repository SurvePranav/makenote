import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable
class AuthUser implements Exception {
  final bool isEmailVerified;

  const AuthUser(this.isEmailVerified);
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
