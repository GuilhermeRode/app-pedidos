import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/produto.dart';
import '../viewmodels/produto_viewmodel.dart';

class ListaProdutosScreen extends StatefulWidget {
  const ListaProdutosScreen({super.key});

  @override
  State<ListaProdutosScreen> createState() => _ListaProdutosScreenState();
}

class _ListaProdutosScreenState extends State<ListaProdutosScreen> {
  final _buscaController = TextEditingController();
  String _busca = '';
  bool? _filtroDisponivel;

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProdutoViewModel>();

    final produtosFiltrados = vm.produtos.where((p) {
      final nomeOk =
      p.nome.toLowerCase().contains(_busca.toLowerCase());
      final dispOk =
          _filtroDisponivel == null || p.disponivel == _filtroDisponivel;
      return nomeOk && dispOk;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Produtos',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // ── Busca ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _buscaController,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _busca = v),
              decoration: InputDecoration(
                hintText: 'Buscar produto...',
                hintStyle:
                const TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon:
                const Icon(Icons.search, color: Color(0xFF6C63FF)),
                suffixIcon: _busca.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: Color(0xFF9CA3AF), size: 18),
                  onPressed: () {
                    _buscaController.clear();
                    setState(() => _busca = '');
                  },
                )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E1E2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: Color(0xFF6C63FF)),
                ),
              ),
            ),
          ),

          // ── Filtros ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FiltroChip(
                  label: 'Todos',
                  selecionado: _filtroDisponivel == null,
                  onTap: () =>
                      setState(() => _filtroDisponivel = null),
                ),
                const SizedBox(width: 8),
                _FiltroChip(
                  label: 'Disponíveis',
                  selecionado: _filtroDisponivel == true,
                  cor: const Color(0xFF10B981),
                  onTap: () =>
                      setState(() => _filtroDisponivel = true),
                ),
                const SizedBox(width: 8),
                _FiltroChip(
                  label: 'Indisponíveis',
                  selecionado: _filtroDisponivel == false,
                  cor: Colors.red,
                  onTap: () =>
                      setState(() => _filtroDisponivel = false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Contador ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${produtosFiltrados.length} produto(s)',
                    style: const TextStyle(
                        color: Color(0xFF9CA3AF), fontSize: 13)),
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
                : produtosFiltrados.isEmpty
                ? _Vazio(
              mensagem: _busca.isNotEmpty
                  ? 'Nenhum produto encontrado para "$_busca"'
                  : 'Nenhum produto cadastrado ainda.',
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: produtosFiltrados.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = produtosFiltrados[i];
                return _ProdutoCard(
                  produto: p,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/detalhes-produto',
                    arguments: p,
                  ).then((_) => context
                      .read<ProdutoViewModel>()
                      .carregarProdutos()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card clicável ─────────────────────────────────────────────────────────────

class _ProdutoCard extends StatelessWidget {
  final Produto produto;
  final VoidCallback onTap;

  const _ProdutoCard({required this.produto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final margem = produto.precoVenda > 0 && produto.precoCusto > 0
        ? ((produto.precoVenda - produto.precoCusto) /
        produto.precoVenda *
        100)
        .toStringAsFixed(1)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.4)),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  color: Color(0xFF3B82F6), size: 20),
            ),
            const SizedBox(width: 12),

            // Dados
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(produto.nome,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: produto.disponivel
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        produto.disponivel
                            ? 'Disponível'
                            : 'Indisponível',
                        style: TextStyle(
                          color: produto.disponivel
                              ? const Color(0xFF10B981)
                              : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    _InfoPreco(
                        label: 'Venda',
                        valor:
                        'R\$ ${produto.precoVenda.toStringAsFixed(2)}',
                        cor: const Color(0xFF10B981)),
                    const SizedBox(width: 16),
                    _InfoPreco(
                        label: 'Custo',
                        valor:
                        'R\$ ${produto.precoCusto.toStringAsFixed(2)}',
                        cor: const Color(0xFF9CA3AF)),
                    if (margem != null) ...[
                      const SizedBox(width: 16),
                      _InfoPreco(
                          label: 'Margem',
                          valor: '$margem%',
                          cor: const Color(0xFFF59E0B)),
                    ],
                  ]),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _InfoPreco extends StatelessWidget {
  final String label, valor;
  final Color cor;
  const _InfoPreco(
      {required this.label, required this.valor, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF9CA3AF), fontSize: 10)),
        Text(valor,
            style: TextStyle(
                color: cor,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
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
    this.cor = const Color(0xFF6C63FF),
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
          const Icon(Icons.inventory_2_outlined,
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