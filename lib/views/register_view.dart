import 'package:flutter/material.dart';
import 'package:makenote/constants/routes.dart';
import 'package:makenote/services/auth/auth_exceptions.dart';
import 'package:makenote/services/auth/auth_service.dart';
import '../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 125, left: 20, right: 20),
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
                      color: Colors.grey),
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
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: TextField(
                            controller: _password,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              hintText: 'Create strong password',
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
                                try {
                                  await AuthService.firebase().createUser(
                                    email: email,
                                    password: password,
                                  );
                                  await AuthService.firebase()
                                      .sendVerificationLink();
                                  if (context.mounted) {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            verifyRoute, (route) => false);
                                  }
                                } on WeakPasswordAuthException {
                                  await showErrorDialog(
                                    context,
                                    'password is too weak',
                                  );
                                } on EmailAlreadyInUseAuthException {
                                  await showErrorDialog(
                                    context,
                                    'User Already Registered',
                                  );
                                } on InvalidEmailAuthException {
                                  await showErrorDialog(
                                    context,
                                    'You entered invalid email id',
                                  );
                                } on GenericAuthException {
                                  await showErrorDialog(
                                    context,
                                    'Failed To Register',
                                  );
                                }
                              },
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Row(
                            children: [
                              const Text(
                                'Already registered?',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, loginRoute, (route) => false);
                                },
                                child: const Text(
                                  'Login Here!',
                                  style: TextStyle(fontSize: 18),
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
