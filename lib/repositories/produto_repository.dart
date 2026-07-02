import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/produto.dart';

class ProdutoRepository {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _colecao = 'produtos';

  Future<List<Produto>> buscarTodos() async {
    final snap = await _db.collection(_colecao).get();
    return snap.docs.map((doc) => Produto.fromMap(doc.id, doc.data())).toList();
  }

  /// Gera um ID de documento novo sem gravar nada ainda.
  /// Usado para poder subir a foto (que precisa de um ID) antes de
  /// salvar o produto em si.
  String gerarId() => _db.collection(_colecao).doc().id;

  Future<void> adicionar(Produto produto) async {
    if (produto.id.isEmpty) {
      await _db.collection(_colecao).add(produto.toMap());
    } else {
      await _db.collection(_colecao).doc(produto.id).set(produto.toMap());
    }
  }

  Future<void> remover(String id) async {
    // Remove a imagem do Storage (se houver) antes de apagar o produto.
    final doc = await _db.collection(_colecao).doc(id).get();
    final path = doc.data()?['imagemPath'] as String?;
    if (path != null && path.isNotEmpty) {
      await _removerImagemPorPath(path);
    }
    await _db.collection(_colecao).doc(id).delete();
  }

  Future<void> atualizar(Produto produto) async {
    await _db.collection(_colecao).doc(produto.id).update(produto.toMap());
  }

  /// Faz upload da foto do produto para o Firebase Storage e retorna
  /// a URL pública de download junto com o path (usado para deletar depois).
  ///
  /// Estrutura no Storage: produtos/{produtoId}/{timestamp}.jpg
  Future<({String url, String path})> uploadImagem({
    required String produtoId,
    required File arquivo,
  }) async {
    final nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'produtos/$produtoId/$nomeArquivo';
    final ref = _storage.ref().child(path);

    await ref.putFile(
      arquivo,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final url = await ref.getDownloadURL();
    return (url: url, path: path);
  }

  /// Remove uma imagem antiga do Storage (usado ao trocar a foto ou
  /// ao excluir o produto). Ignora erro caso o arquivo já não exista.
  Future<void> _removerImagemPorPath(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (_) {
      // Arquivo pode já ter sido removido; não é um erro crítico.
    }
  }

  Future<void> removerImagem(String path) => _removerImagemPorPath(path);
}
