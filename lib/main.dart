import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'views/login_screen.dart';
import 'views/criar_conta_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAH0eRbCIUelTKSCnc5td-S7e8BzxK0iHw",
      appId: "1:816945693857:android:1ea5d3442f9867647adce0",
      messagingSenderId: "816945693857",
      projectId: "pedido-app-769f9",
      storageBucket: "pedido-app-769f9.firebasestorage.app",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'Pedido App',
        debugShowCheckedModeBanner: false,
        initialRoute: FirebaseAuth.instance.currentUser != null ? '/home' : '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/criar-conta': (_) => const CriarContaScreen(),
          '/home': (_) => const Scaffold(
            backgroundColor: Color(0xFF0F0F1A),
            body: Center(
              child: Text(
                'Home em breve!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        },
      ),
    );
  }
}