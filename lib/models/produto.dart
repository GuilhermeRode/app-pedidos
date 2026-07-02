class Produto {
  final String id;
  final String nome;
  final double precoVenda;
  final double precoCusto;
  final bool disponivel;
  final String? imagemUrl;
  final String? imagemPath;

  Produto({
    required this.id,
    required this.nome,
    required this.precoVenda,
    required this.precoCusto,
    required this.disponivel,
    this.imagemUrl,
    this.imagemPath,
  });

  factory Produto.fromMap(String id, Map<String, dynamic> map) {
    return Produto(
      id: id,
      nome: map['nome'] ?? '',
      precoVenda: (map['precoVenda'] ?? 0).toDouble(),
      precoCusto: (map['precoCusto'] ?? 0).toDouble(),
      disponivel: map['disponivel'] ?? true,
      imagemUrl: map['imagemUrl'] as String?,
      imagemPath: map['imagemPath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'precoVenda': precoVenda,
      'precoCusto': precoCusto,
      'disponivel': disponivel,
      'imagemUrl': imagemUrl,
      'imagemPath': imagemPath,
    };
  }

  Produto copyWith({
    String? id,
    String? nome,
    double? precoVenda,
    double? precoCusto,
    bool? disponivel,
    String? imagemUrl,
    String? imagemPath,
    bool limparImagem = false,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      precoVenda: precoVenda ?? this.precoVenda,
      precoCusto: precoCusto ?? this.precoCusto,
      disponivel: disponivel ?? this.disponivel,
      imagemUrl: limparImagem ? null : (imagemUrl ?? this.imagemUrl),
      imagemPath: limparImagem ? null : (imagemPath ?? this.imagemPath),
    );
  }
}
