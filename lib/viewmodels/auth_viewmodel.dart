import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool carregando = false;
  String? erro;

  Future<bool> login(String email, String senha) async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      carregando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      erro = e.code == 'user-not-found'
          ? 'Usuário não encontrado.'
          : e.code == 'wrong-password'
              ? 'Senha incorreta.'
              : 'Erro ao fazer login.';
      carregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> criarConta(String nome, String email, String senha) async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: senha);
      await result.user?.updateDisplayName(nome);
      carregando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      erro = e.code == 'email-already-in-use'
          ? 'Este e-mail já está em uso.'
          : 'Erro ao criar conta.';
      carregando = false;
      notifyListeners();
      return false;
    }
  }

  void logout() => _auth.signOut();
}
