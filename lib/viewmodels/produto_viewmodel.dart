import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../repositories/produto_repository.dart';

class ProdutoViewModel extends ChangeNotifier {
  final _repository = ProdutoRepository();

  List<Produto> produtos = [];
  bool carregando = false;
  String? erro;

  Future<void> carregarProdutos() async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      produtos = await _repository.buscarTodos();
    } catch (e) {
      erro = 'Erro ao carregar produtos.';
    }

    carregando = false;
    notifyListeners();
  }

  Future<bool> adicionarProduto(Produto produto) async {
    try {
      await _repository.adicionar(produto);
      await carregarProdutos();
      return true;
    } catch (e) {
      erro = 'Erro ao adicionar produto.';
      notifyListeners();
      return false;
    }
  }

  Future<void> removerProduto(String id) async {
    await _repository.remover(id);
    await carregarProdutos();
  }
}
