class Produto {
  final String id;
  final String nome;
  final double precoVenda;
  final double precoCusto;
  final bool disponivel;

  Produto({
    required this.id,
    required this.nome,
    required this.precoVenda,
    required this.precoCusto,
    required this.disponivel,
  });

  factory Produto.fromMap(String id, Map<String, dynamic> map) {
    return Produto(
      id: id,
      nome: map['nome'] ?? '',
      precoVenda: (map['precoVenda'] ?? 0).toDouble(),
      precoCusto: (map['precoCusto'] ?? 0).toDouble(),
      disponivel: map['disponivel'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'precoVenda': precoVenda,
      'precoCusto': precoCusto,
      'disponivel': disponivel,
    };
  }
}
