import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cliente.dart';
import '../viewmodels/cliente_viewmodel.dart';

class DetalhesClienteScreen extends StatelessWidget {
  const DetalhesClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cliente =
    ModalRoute.of(context)!.settings.arguments as Cliente;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detalhes do Cliente',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmarExclusao(context, cliente),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Avatar + nome ───────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF6C63FF).withOpacity(0.4),
                          width: 2),
                    ),
                    child: Center(
                      child: Text(
                        cliente.nome.isNotEmpty
                            ? cliente.nome[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(cliente.nome,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: cliente.ativo
                          ? const Color(0xFF10B981).withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cliente.ativo ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                          color: cliente.ativo
                              ? const Color(0xFF10B981)
                              : Colors.red,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Dados de contato ────────────────────────────────────────
            _Secao(titulo: 'Contato', children: [
              if (cliente.celular.isNotEmpty) ...[
                _LinhaDetalhe(
                  icone: Icons.phone_outlined,
                  label: 'Celular',
                  valor: cliente.celular,
                ),
                const SizedBox(height: 14),
              ],
              if (cliente.email.isNotEmpty)
                _LinhaDetalhe(
                  icone: Icons.email_outlined,
                  label: 'E-mail',
                  valor: cliente.email,
                ),
              if (cliente.celular.isEmpty && cliente.email.isEmpty)
                const Text('Nenhum contato cadastrado.',
                    style: TextStyle(color: Color(0xFF9CA3AF))),
            ]),

            const SizedBox(height: 24),

            // ── Botão editar ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/editar-cliente',
                  arguments: cliente,
                ).then((_) => Navigator.pop(context)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.white),
                label: const Text(
                  'Editar Cliente',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, Cliente cliente) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir cliente',
            style: TextStyle(color: Colors.white)),
        content: Text(
            'Deseja excluir "${cliente.nome}"? Esta ação não pode ser desfeita.',
            style: const TextStyle(color: Color(0xFF9CA3AF))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<ClienteViewModel>()
                  .removerCliente(cliente.id);
              Navigator.pop(context); // fecha dialog
              Navigator.pop(context); // volta para lista
            },
            child: const Text('Excluir',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _Secao extends StatelessWidget {
  final String titulo;
  final List<Widget> children;
  const _Secao({required this.titulo, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children),
        ),
      ],
    );
  }
}

class _LinhaDetalhe extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;
  const _LinhaDetalhe(
      {required this.icone, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, color: const Color(0xFF6C63FF), size: 18),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF9CA3AF), fontSize: 11)),
          const SizedBox(height: 2),
          Text(valor,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ]),
      ],
    );
  }
}