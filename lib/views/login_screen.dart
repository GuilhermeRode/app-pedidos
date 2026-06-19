import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.storefront_rounded,
                    color: Color(0xFF6C63FF), size: 40),
              ),
              const SizedBox(height: 24),
              const Text('Bem-vindo de volta',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Faça login para continuar',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16)),
              const SizedBox(height: 40),
              _Campo(
                controller: _emailController,
                label: 'E-mail',
                icone: Icons.email_outlined,
                teclado: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _Campo(
                controller: _senhaController,
                label: 'Senha',
                icone: Icons.lock_outline,
                obscuro: !_senhaVisivel,
                sufixo: IconButton(
                  icon: Icon(
                    _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF9CA3AF),
                  ),
                  onPressed: () =>
                      setState(() => _senhaVisivel = !_senhaVisivel),
                ),
              ),
              const SizedBox(height: 32),
              if (vm.erro != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Text(vm.erro!,
                        style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ]),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: vm.carregando
                      ? null
                      : () async {
                          final ok = await vm.login(
                            _emailController.text.trim(),
                            _senhaController.text.trim(),
                          );
                          if (ok && context.mounted) {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: vm.carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Entrar',
                          style:
                              TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Não tem conta?',
                      style: TextStyle(color: Color(0xFF9CA3AF))),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/criar-conta'),
                    child: const Text('Criar conta',
                        style: TextStyle(color: Color(0xFF6C63FF))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icone;
  final bool obscuro;
  final TextInputType? teclado;
  final Widget? sufixo;

  const _Campo({
    required this.controller,
    required this.label,
    required this.icone,
    this.obscuro = false,
    this.teclado,
    this.sufixo,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscuro,
      keyboardType: teclado,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        prefixIcon: Icon(icone, color: const Color(0xFF6C63FF)),
        suffixIcon: sufixo,
        filled: true,
        fillColor: const Color(0xFF1E1E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
      ),
    );
  }
}
