import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente.dart';

class ClienteRepository {
  final _db = FirebaseFirestore.instance;
  final _colecao = 'clientes';

  Future<List<Cliente>> buscarTodos() async {
    final snap = await _db.collection(_colecao).get();
    return snap.docs.map((doc) => Cliente.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> adicionar(Cliente cliente) async {
    await _db.collection(_colecao).add(cliente.toMap());
  }

  Future<void> remover(String id) async {
    await _db.collection(_colecao).doc(id).delete();
  }

  Future<void> atualizar(Cliente cliente) async {
    await _db.collection(_colecao).doc(cliente.id).update(cliente.toMap());
  }
}
