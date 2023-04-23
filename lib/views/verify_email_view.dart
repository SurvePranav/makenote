import 'package:flutter/material.dart';
import 'package:makenote/constants/routes.dart';
import 'package:makenote/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'We\'ve sent a verification link on your email address. Click on link to verify your account.\nCheck your spam folder if not found',
              style: TextStyle(fontSize: 18),
            ),
            Row(
              children: [
                const Text(
                  'email not received?',
                  style: TextStyle(fontSize: 18),
                ),
                TextButton(
                  onPressed: () async {
                    await AuthService.firebase().sendVerificationLink();
                  },
                  child: const Text('Click Here'),
                ),
                const Text(
                  'to resend.',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () async {
                  await AuthService.firebase().logOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute, (route) => false);
                  }
                },
                child: const Text('Back to registation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
