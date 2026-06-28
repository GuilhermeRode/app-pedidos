import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../repositories/cliente_repository.dart';

class ClienteViewModel extends ChangeNotifier {
  final _repository = ClienteRepository();

  List<Cliente> clientes = [];
  bool carregando = false;
  String? erro;

  Future<void> carregarClientes() async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      clientes = await _repository.buscarTodos();
    } catch (e) {
      erro = 'Erro ao carregar clientes.';
    }

    carregando = false;
    notifyListeners();
  }

  Future<bool> adicionarCliente(Cliente cliente) async {
    try {
      await _repository.adicionar(cliente);
      await carregarClientes();
      return true;
    } catch (e) {
      erro = 'Erro ao adicionar cliente.';
      notifyListeners();
      return false;
    }
  }

  Future<void> removerCliente(String id) async {
    await _repository.remover(id);
    await carregarClientes();
  }

  Future<bool> atualizarCliente(Cliente cliente) async {
    try {
      await _repository.atualizar(cliente);
      await carregarClientes();
      return true;
    } catch (e) {
      erro = 'Erro ao atualizar cliente.';
      notifyListeners();
      return false;
    }
  }
}
