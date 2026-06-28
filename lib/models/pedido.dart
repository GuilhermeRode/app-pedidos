import 'package:cloud_firestore/cloud_firestore.dart';

class ItemPedido {
  final String produtoId;
  final String nomeProduto;
  final int quantidade;
  final double precoUnitario;

  ItemPedido({
    required this.produtoId,
    required this.nomeProduto,
    required this.quantidade,
    required this.precoUnitario,
  });

  double get subtotal => quantidade * precoUnitario;

  Map<String, dynamic> toMap() => {
        'produtoId': produtoId,
        'nomeProduto': nomeProduto,
        'quantidade': quantidade,
        'precoUnitario': precoUnitario,
      };

  factory ItemPedido.fromMap(Map<String, dynamic> map) => ItemPedido(
        produtoId: map['produtoId'] ?? '',
        nomeProduto: map['nomeProduto'] ?? '',
        quantidade: map['quantidade'] ?? 1,
        precoUnitario: (map['precoUnitario'] ?? 0).toDouble(),
      );
}

class Pedido {
  final String id;
  final String clienteId;
  final String nomeCliente;
  final List<ItemPedido> itens;
  final String status;
  final DateTime data;
  final double desconto;

  Pedido({
    required this.id,
    required this.clienteId,
    required this.nomeCliente,
    required this.itens,
    required this.status,
    required this.data,
    required this.desconto,
  });

  double get total =>
      itens.fold(0.0, (sum, item) => sum + item.subtotal) - desconto;

  factory Pedido.fromMap(String id, Map<String, dynamic> map) {
    return Pedido(
      id: id,
      clienteId: map['clienteId'] ?? '',
      nomeCliente: map['nomeCliente'] ?? '',
      itens: (map['itens'] as List<dynamic>? ?? [])
          .map((i) => ItemPedido.fromMap(i as Map<String, dynamic>))
          .toList(),
      status: map['status'] ?? 'pendente',
      data: (map['data'] as Timestamp).toDate(),
      desconto: (map['desconto'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'clienteId': clienteId,
        'nomeCliente': nomeCliente,
        'itens': itens.map((i) => i.toMap()).toList(),
        'status': status,
        'data': Timestamp.fromDate(data),
        'desconto': desconto,
      };

  Pedido copyWith({
    String? id,
    String? clienteId,
    String? nomeCliente,
    List<ItemPedido>? itens,
    String? status,
    DateTime? data,
    double? desconto,
  }) {
    return Pedido(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      nomeCliente: nomeCliente ?? this.nomeCliente,
      itens: itens ?? this.itens,
      status: status ?? this.status,
      data: data ?? this.data,
      desconto: desconto ?? this.desconto,
    );
  }
}
