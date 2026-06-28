import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido.dart';

class PedidoRepository {
  final _db = FirebaseFirestore.instance;
  final _colecao = 'pedidos';

  Future<List<Pedido>> buscarTodos() async {
    final snap = await _db.collection(_colecao).orderBy('data', descending: true).get();
    return snap.docs.map((doc) => Pedido.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> adicionar(Pedido pedido) async {
    await _db.collection(_colecao).add(pedido.toMap());
  }

  Future<void> remover(String id) async {
    await _db.collection(_colecao).doc(id).delete();
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    await _db.collection(_colecao).doc(id).update({'status': novoStatus});
  }

  Future<void> atualizar(Pedido pedido) async {
    await _db.collection(_colecao).doc(pedido.id).update(pedido.toMap());
  }
}
