import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:makenote/constants/routes.dart';
import 'package:makenote/views/register_view.dart';
import 'package:makenote/views/verify_email_view.dart';
import 'firebase_options.dart';
import 'views/login_view.dart';
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyRoute: (context) => const VerifyEmailView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                return const NotesView();
              } else {
                return const NotesView();
              }
            } else {
              return const LoginView();
            }

          default:
            return const Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }
}

enum MenuAction { logout, login }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            devtools.log(value.toString());
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                devtools.log(shouldLogout.toString());
                if (shouldLogout) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (_) => false,
                  );
                }
                break;
              case MenuAction.login:
                devtools.log('login pressed');
                break;
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('logout'),
              ),
            ];
          })
        ],
      ),
      body: const Center(
        child: Text('Main UI Of App'),
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);

              await FirebaseAuth.instance.signOut();
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
