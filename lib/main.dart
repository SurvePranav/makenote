import 'package:flutter/material.dart';
import 'package:makenote/constants/routes.dart';
import 'package:makenote/services/auth/auth_service.dart';
import 'package:makenote/views/notes/create_update_note_view.dart';
import 'package:makenote/views/notes/notes_view.dart';
import 'package:makenote/views/register_view.dart';
import 'package:makenote/views/verify_email_view.dart';
import 'package:makenote/views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.grey,
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Colors.grey,
        ),
        scaffoldBackgroundColor: Colors.grey,
        appBarTheme: const AppBarTheme(
          color: Colors.grey, // Background color of AppBar
          elevation: 0.0, // Shadow the AppBar casts
          iconTheme: IconThemeData(
            color: Colors.black,
          ), // Color of icons in AppBar
          // You can add more properties as needed
        ),
      ),

      home: const HomePage(),
      // home: const TestingPage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyRoute: (context) => const VerifyEmailView(),
        createAndUpdateNoteRout: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
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
