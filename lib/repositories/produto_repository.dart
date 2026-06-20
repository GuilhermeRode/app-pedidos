import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/produto.dart';

class ProdutoRepository {
  final _db = FirebaseFirestore.instance;
  final _colecao = 'produtos';

  Future<List<Produto>> buscarTodos() async {
    final snap = await _db.collection(_colecao).get();
    return snap.docs.map((doc) => Produto.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> adicionar(Produto produto) async {
    await _db.collection(_colecao).add(produto.toMap());
  }

  Future<void> remover(String id) async {
    await _db.collection(_colecao).doc(id).delete();
  }
}
