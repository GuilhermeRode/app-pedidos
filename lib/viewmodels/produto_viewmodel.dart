import 'dart:io';
import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../repositories/produto_repository.dart';

class ProdutoViewModel extends ChangeNotifier {
  final _repository = ProdutoRepository();

  List<Produto> produtos = [];
  bool carregando = false;
  bool enviandoImagem = false;
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

  /// Adiciona um produto, opcionalmente com uma foto.
  /// Se [imagem] for informada, o ID do produto é gerado antes,
  /// a foto é enviada ao Firebase Storage e só então o documento
  /// é salvo no Firestore já com a imagemUrl/imagemPath.
  Future<bool> adicionarProduto(Produto produto, {File? imagem}) async {
    try {
      var produtoParaSalvar = produto;

      if (imagem != null) {
        final id = _repository.gerarId();
        enviandoImagem = true;
        notifyListeners();

        final resultado = await _repository.uploadImagem(
          produtoId: id,
          arquivo: imagem,
        );

        enviandoImagem = false;
        produtoParaSalvar = produto.copyWith(
          id: id,
          imagemUrl: resultado.url,
          imagemPath: resultado.path,
        );
      }

      await _repository.adicionar(produtoParaSalvar);
      await carregarProdutos();
      return true;
    } catch (e) {
      enviandoImagem = false;
      erro = 'Erro ao adicionar produto.';
      notifyListeners();
      return false;
    }
  }

  Future<void> removerProduto(String id) async {
    await _repository.remover(id);
    await carregarProdutos();
  }

  /// Atualiza um produto, opcionalmente substituindo a foto.
  /// Se [novaImagem] for informada, a foto antiga (se existir) é
  /// removida do Storage e a nova é enviada no lugar.
  Future<bool> atualizarProduto(Produto produto, {File? novaImagem}) async {
    try {
      var produtoParaSalvar = produto;

      if (novaImagem != null) {
        enviandoImagem = true;
        notifyListeners();

        if (produto.imagemPath != null && produto.imagemPath!.isNotEmpty) {
          await _repository.removerImagem(produto.imagemPath!);
        }

        final resultado = await _repository.uploadImagem(
          produtoId: produto.id,
          arquivo: novaImagem,
        );

        enviandoImagem = false;
        produtoParaSalvar = produto.copyWith(
          imagemUrl: resultado.url,
          imagemPath: resultado.path,
        );
      }

      await _repository.atualizar(produtoParaSalvar);
      await carregarProdutos();
      return true;
    } catch (e) {
      enviandoImagem = false;
      erro = 'Erro ao atualizar produto.';
      notifyListeners();
      return false;
    }
  }
}
