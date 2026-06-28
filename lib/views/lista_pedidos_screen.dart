import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../viewmodels/pedido_viewmodel.dart';

class ListaPedidosScreen extends StatefulWidget {
  const ListaPedidosScreen({super.key});

  @override
  State<ListaPedidosScreen> createState() => _ListaPedidosScreenState();
}

class _ListaPedidosScreenState extends State<ListaPedidosScreen> {
  String? _filtroStatus;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PedidoViewModel>();

    final pedidosFiltrados = _filtroStatus == null
        ? vm.pedidos
        : vm.pedidos.where((p) => p.status == _filtroStatus).toList();

    final totalFiltrado =
    pedidosFiltrados.fold(0.0, (sum, p) => sum + p.total);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Pedidos',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // ── Filtros ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FiltroChip(
                    label: 'Todos',
                    selecionado: _filtroStatus == null,
                    cor: const Color(0xFF6C63FF),
                    onTap: () => setState(() => _filtroStatus = null),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Pendente',
                    selecionado: _filtroStatus == 'pendente',
                    cor: const Color(0xFFF59E0B),
                    onTap: () =>
                        setState(() => _filtroStatus = 'pendente'),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Concluído',
                    selecionado: _filtroStatus == 'concluido',
                    cor: const Color(0xFF10B981),
                    onTap: () =>
                        setState(() => _filtroStatus = 'concluido'),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Cancelado',
                    selecionado: _filtroStatus == 'cancelado',
                    cor: Colors.red,
                    onTap: () =>
                        setState(() => _filtroStatus = 'cancelado'),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Orçamento',
                    selecionado: _filtroStatus == 'orcamento',
                    cor: const Color(0xFF3B82F6),
                    onTap: () =>
                        setState(() => _filtroStatus = 'orcamento'),
                  ),
                ],
              ),
            ),
          ),

          // ── Contador + total ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${pedidosFiltrados.length} pedido(s)',
                    style: const TextStyle(
                        color: Color(0xFF9CA3AF), fontSize: 13)),
                Text(
                    'Total: R\$ ${totalFiltrado.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Lista ────────────────────────────────────────────────────
          Expanded(
            child: vm.carregando
                ? const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF6C63FF)))
                : pedidosFiltrados.isEmpty
                ? _Vazio(
              mensagem: _filtroStatus != null
                  ? 'Nenhum pedido com status "${_labelStatus(_filtroStatus!)}".'
                  : 'Nenhum pedido registrado ainda.',
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: pedidosFiltrados.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = pedidosFiltrados[i];
                return _PedidoCard(
                  pedido: p,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/detalhes-pedido',
                    arguments: p,
                  ).then((_) => context
                      .read<PedidoViewModel>()
                      .carregarPedidos()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card clicável — sem lixeira, sem botão de + ──────────────────────────────

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;

  const _PedidoCard({required this.pedido, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cor = _corStatus(pedido.status);
    final data =
        '${pedido.data.day.toString().padLeft(2, '0')}/'
        '${pedido.data.month.toString().padLeft(2, '0')}/'
        '${pedido.data.year}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: cor, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: cliente + badge de status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.person_outline,
                      color: Color(0xFF9CA3AF), size: 16),
                  const SizedBox(width: 6),
                  Text(pedido.nomeCliente,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ]),
                _BadgeStatus(status: pedido.status),
              ],
            ),

            const SizedBox(height: 10),

            // Resumo dos itens
            Text(
              pedido.itens
                  .take(2)
                  .map((i) => '${i.quantidade}x ${i.nomeProduto}')
                  .join(', ') +
                  (pedido.itens.length > 2
                      ? ' +${pedido.itens.length - 2} mais'
                      : ''),
              style: const TextStyle(
                  color: Color(0xFF9CA3AF), fontSize: 13),
            ),

            const SizedBox(height: 10),
            const Divider(color: Color(0xFF2A2A3E), height: 1),
            const SizedBox(height: 10),

            // Rodapé: data, desconto e total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: Color(0xFF9CA3AF), size: 13),
                  const SizedBox(width: 4),
                  Text(data,
                      style: const TextStyle(
                          color: Color(0xFF9CA3AF), fontSize: 13)),
                  if (pedido.desconto > 0) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.local_offer_outlined,
                        color: Color(0xFFF59E0B), size: 13),
                    const SizedBox(width: 4),
                    Text(
                        '-R\$ ${pedido.desconto.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Color(0xFFF59E0B), fontSize: 13)),
                  ],
                ]),
                Row(children: [
                  Text(
                      'R\$ ${pedido.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(width: 6),
                  // Indica que é clicável
                  const Icon(Icons.chevron_right,
                      color: Color(0xFF9CA3AF), size: 18),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _BadgeStatus extends StatelessWidget {
  final String status;
  const _BadgeStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    final cor = _corStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withOpacity(0.4)),
      ),
      child: Text(
        _labelStatus(status),
        style: TextStyle(
            color: cor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selecionado;
  final Color cor;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.selecionado,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selecionado
              ? cor.withOpacity(0.15)
              : const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selecionado ? cor : const Color(0xFF3A3A4E)),
        ),
        child: Text(label,
            style: TextStyle(
                color: selecionado ? cor : const Color(0xFF9CA3AF),
                fontSize: 13,
                fontWeight: selecionado
                    ? FontWeight.w600
                    : FontWeight.normal)),
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  final String mensagem;
  const _Vazio({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined,
              color: Color(0xFF3A3A4E), size: 64),
          const SizedBox(height: 16),
          Text(mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF9CA3AF), fontSize: 14)),
        ],
      ),
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