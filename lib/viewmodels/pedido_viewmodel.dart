import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../repositories/pedido_repository.dart';

class PedidoViewModel extends ChangeNotifier {
  final _repository = PedidoRepository();

  List<Pedido> pedidos = [];
  bool carregando = false;
  String? erro;

  Future<void> carregarPedidos() async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      pedidos = await _repository.buscarTodos();
    } catch (e) {
      erro = 'Erro ao carregar pedidos.';
    }

    carregando = false;
    notifyListeners();
  }

  Future<bool> adicionarPedido(Pedido pedido) async {
    try {
      await _repository.adicionar(pedido);
      await carregarPedidos();
      return true;
    } catch (e) {
      erro = 'Erro ao adicionar pedido.';
      notifyListeners();
      return false;
    }
  }

  Future<void> removerPedido(String id) async {
    await _repository.remover(id);
    await carregarPedidos();
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    await _repository.atualizarStatus(id, novoStatus);
    await carregarPedidos();
  }
}
