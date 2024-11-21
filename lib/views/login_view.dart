import 'package:flutter/material.dart';
import 'package:makenote/constants/routes.dart';
import 'package:makenote/services/auth/auth_exceptions.dart';
import 'package:makenote/services/auth/auth_service.dart';
import 'package:makenote/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _setLoginText();
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget _myChild = const Text(
    'Login',
    style: TextStyle(
      fontSize: 20,
    ),
  );
  void _setLoginText() {
    setState(() {
      _myChild = const Text(
        'Login',
        style: TextStyle(
          fontSize: 20,
        ),
      );
    });
  }

  void _setLoadingCircle() {
    setState(() {
      _myChild = const CircularProgressIndicator();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Text(
                'Get Started!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: MediaQuery.of(context).size.width > 700
                  ? EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.25,
                      vertical: 120)
                  : const EdgeInsets.only(top: 125, left: 20, right: 20),
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 18, 109, 109),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: 14.0,
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _email,
                          autocorrect: false,
                          style: const TextStyle(color: Colors.black),
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: TextField(
                            controller: _password,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: 'Enter your password',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0, bottom: 20),
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                final email = _email.text;
                                final password = _password.text;

                                _setLoadingCircle();
                                try {
                                  await AuthService.firebase().logIn(
                                    email: email,
                                    password: password,
                                  );
                                  final user =
                                      AuthService.firebase().currentUser;
                                  if (user?.isEmailVerified ?? false) {
                                    _setLoginText();
                                    // user email is verified
                                    if (context.mounted) {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                        notesRoute,
                                        (route) => false,
                                      );
                                    }
                                  } else {
                                    _setLoginText();
                                    // user email is not verified
                                    if (context.mounted) {
                                      Navigator.of(context).pushNamed(
                                        verifyRoute,
                                        // (route) => false,
                                      );
                                    }
                                  }
                                } on UserNotFoundAuthException {
                                  _setLoginText();
                                  await showErrorDialog(
                                    context,
                                    'User Not Found',
                                  );
                                } on WrongPasswordAuthException {
                                  _setLoginText();
                                  await showErrorDialog(
                                    context,
                                    'Wrong Password',
                                  );
                                } on GenericAuthException {
                                  _setLoginText();
                                  await showErrorDialog(
                                    context,
                                    'Authentication Error',
                                  );
                                }
                              },
                              child: _myChild,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Row(
                            children: [
                              const Text(
                                'Not registered yet?',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(registerRoute);
                                },
                                child: const Text(
                                  'Register here',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
