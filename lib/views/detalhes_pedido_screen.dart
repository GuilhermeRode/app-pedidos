import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../viewmodels/pedido_viewmodel.dart';

class DetalhesPedidoScreen extends StatelessWidget {
  const DetalhesPedidoScreen({super.key});

  // Pedidos editáveis
  static const _editaveis = {'pendente', 'orcamento'};

  @override
  Widget build(BuildContext context) {
    final pedido = ModalRoute.of(context)!.settings.arguments as Pedido;
    final podeEditar = _editaveis.contains(pedido.status);
    final cor = _corStatus(pedido.status);

    final data =
        '${pedido.data.day.toString().padLeft(2, '0')}/'
        '${pedido.data.month.toString().padLeft(2, '0')}/'
        '${pedido.data.year}';

    final subtotal =
    pedido.itens.fold(0.0, (sum, i) => sum + i.subtotal);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detalhes do Pedido',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          // Lixeira — sempre disponível
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmarExclusao(context, pedido),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Banner de status ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: cor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cor.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: cor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _labelStatus(pedido.status),
                    style: TextStyle(
                        color: cor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  if (!podeEditar) ...[
                    const Spacer(),
                    Icon(Icons.lock_outline, color: cor, size: 16),
                    const SizedBox(width: 4),
                    Text('Bloqueado',
                        style: TextStyle(color: cor, fontSize: 12)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Alterar Status ──────────────────────────────────────────────
            _Secao(titulo: 'Alterar Status', children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ['pendente', 'orcamento', 'concluido', 'cancelado']
                    .map((s) {
                  final cor = _corStatus(s);
                  final ativo = s == pedido.status;
                  return GestureDetector(
                    onTap: ativo
                        ? null
                        : () {
                      context
                          .read<PedidoViewModel>()
                          .atualizarStatus(pedido.id, s);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: ativo
                            ? cor.withOpacity(0.2)
                            : const Color(0xFF2A2A3E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ativo ? cor : const Color(0xFF3A3A4E),
                        ),
                      ),
                      child: Text(
                        _labelStatus(s),
                        style: TextStyle(
                          color: ativo ? cor : const Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontWeight:
                          ativo ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),

            const SizedBox(height: 24),

            // ── Seção: Cliente e data ───────────────────────────────────
            _Secao(titulo: 'Informações', children: [
              _LinhaDetalhe(
                icone: Icons.person_outline,
                label: 'Cliente',
                valor: pedido.nomeCliente,
              ),
              const SizedBox(height: 14),
              _LinhaDetalhe(
                icone: Icons.calendar_today_outlined,
                label: 'Data',
                valor: data,
              ),
              const SizedBox(height: 14),
              _LinhaDetalhe(
                icone: Icons.receipt_outlined,
                label: 'Nº de itens',
                valor: '${pedido.itens.length} item(s)',
              ),
            ]),

            const SizedBox(height: 24),

            // ── Seção: Itens ───────────────────────────────────────────
            _Secao(titulo: 'Itens do Pedido', children: [
              ...pedido.itens.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    if (i > 0)
                      const Divider(
                          color: Color(0xFF2A2A3E), height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Color(0xFF3B82F6),
                              size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(item.nomeProduto,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantidade}x  R\$ ${item.precoUnitario.toStringAsFixed(2)} un.',
                                style: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'R\$ ${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ]),

            const SizedBox(height: 24),

            // ── Seção: Resumo financeiro ────────────────────────────────
            _Secao(titulo: 'Resumo', children: [
              _LinhaValor(
                  label: 'Subtotal',
                  valor: 'R\$ ${subtotal.toStringAsFixed(2)}',
                  corValor: Colors.white),
              if (pedido.desconto > 0) ...[
                const SizedBox(height: 10),
                _LinhaValor(
                    label: 'Desconto',
                    valor:
                    '- R\$ ${pedido.desconto.toStringAsFixed(2)}',
                    corValor: const Color(0xFFF59E0B)),
              ],
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF2A2A3E)),
              const SizedBox(height: 12),
              _LinhaValor(
                label: 'Total',
                valor: 'R\$ ${pedido.total.toStringAsFixed(2)}',
                corValor: const Color(0xFF6C63FF),
                negrito: true,
                fontSize: 18,
              ),
            ]),

            const SizedBox(height: 32),

            // ── Botão Editar ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: podeEditar
                    ? () => Navigator.pushNamed(
                  context,
                  '/editar-pedido',
                  arguments: pedido,
                ).then((_) => Navigator.pop(context))
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  disabledBackgroundColor:
                  const Color(0xFF3A3A4E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(
                  podeEditar ? Icons.edit_outlined : Icons.lock_outline,
                  color: podeEditar
                      ? Colors.white
                      : const Color(0xFF9CA3AF),
                ),
                label: Text(
                  podeEditar
                      ? 'Editar Pedido'
                      : 'Edição bloqueada — pedido ${_labelStatus(pedido.status).toLowerCase()}',
                  style: TextStyle(
                    fontSize: 15,
                    color: podeEditar
                        ? Colors.white
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, Pedido pedido) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir pedido',
            style: TextStyle(color: Colors.white)),
        content: Text(
            'Deseja excluir o pedido de "${pedido.nomeCliente}"? Esta ação não pode ser desfeita.',
            style: const TextStyle(color: Color(0xFF9CA3AF))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          TextButton(
            onPressed: () {
              context.read<PedidoViewModel>().removerPedido(pedido.id);
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

class _LinhaValor extends StatelessWidget {
  final String label;
  final String valor;
  final Color corValor;
  final bool negrito;
  final double fontSize;

  const _LinhaValor({
    required this.label,
    required this.valor,
    required this.corValor,
    this.negrito = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: negrito ? Colors.white : const Color(0xFF9CA3AF),
                fontSize: fontSize,
                fontWeight:
                negrito ? FontWeight.bold : FontWeight.normal)),
        Text(valor,
            style: TextStyle(
                color: corValor,
                fontSize: fontSize,
                fontWeight:
                negrito ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _labelStatus(String status) {
  switch (status) {
    case 'pendente':  return 'Pendente';
    case 'concluido': return 'Concluído';
    case 'cancelado': return 'Cancelado';
    case 'orcamento': return 'Orçamento';
    default:          return status;
  }
}

Color _corStatus(String status) {
  switch (status) {
    case 'pendente':  return const Color(0xFFF59E0B);
    case 'concluido': return const Color(0xFF10B981);
    case 'cancelado': return Colors.red;
    case 'orcamento': return const Color(0xFF3B82F6);
    default:          return const Color(0xFF9CA3AF);
  }
}