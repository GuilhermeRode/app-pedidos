import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/cliente_viewmodel.dart';
import 'viewmodels/produto_viewmodel.dart';
import 'viewmodels/pedido_viewmodel.dart';

import 'views/login_screen.dart';
import 'views/criar_conta_screen.dart';
import 'views/main_shell.dart';
import 'views/add_cliente_screen.dart';
import 'views/add_produto_screen.dart';
import 'views/add_pedido_screen.dart';
import 'views/editar_pedido_screen.dart';
import 'views/detalhes_pedido_screen.dart';

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
        ChangeNotifierProvider(create: (_) => ClienteViewModel()),
        ChangeNotifierProvider(create: (_) => ProdutoViewModel()),
        ChangeNotifierProvider(create: (_) => PedidoViewModel()),
      ],
      child: MaterialApp(
        title: 'Pedido App',
        debugShowCheckedModeBanner: false,
        initialRoute:
        FirebaseAuth.instance.currentUser != null ? '/shell' : '/login',
        routes: {
          '/login':             (_) => const LoginScreen(),
          '/criar-conta':       (_) => const CriarContaScreen(),
          '/shell':             (_) => const MainShell(),
          '/adicionar-cliente': (_) => const AdicionarClienteScreen(),
          '/adicionar-produto': (_) => const AdicionarProdutoScreen(),
          '/novo-pedido':       (_) => const AdicionarPedidoScreen(),
          '/detalhes-pedido': (_) => const DetalhesPedidoScreen(),
          '/editar-pedido':   (_) => const EditarPedidoScreen(),
        },
      ),
    );
  }
}