class Cliente {
  final String id;
  final String nome;
  final String celular;
  final String email;
  final bool ativo;

  Cliente({
    required this.id,
    required this.nome,
    required this.celular,
    required this.email,
    required this.ativo,
  });

  factory Cliente.fromMap(String id, Map<String, dynamic> map) {
    return Cliente(
      id: id,
      nome: map['nome'] ?? '',
      celular: map['celular'] ?? '',
      email: map['email'] ?? '',
      ativo: map['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'celular': celular,
      'email': email,
      'ativo': ativo,
    };
  }

  Cliente copyWith({
    String? id,
    String? nome,
    String? celular,
    String? email,
    bool? ativo,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      celular: celular ?? this.celular,
      email: email ?? this.email,
      ativo: ativo ?? this.ativo,
    );
  }
}
