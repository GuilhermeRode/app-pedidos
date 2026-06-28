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
  // null = todos, true = disponível, false = indisponível
  bool? _filtroDisponivel;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProdutoViewModel>().carregarProdutos());
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Produtos',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _buscaController,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _busca = v),
              decoration: InputDecoration(
                hintText: 'Buscar produto...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
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

          // Filtros de disponibilidade
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FiltroChip(
                  label: 'Todos',
                  selecionado: _filtroDisponivel == null,
                  onTap: () => setState(() => _filtroDisponivel = null),
                ),
                const SizedBox(width: 8),
                _FiltroChip(
                  label: 'Disponíveis',
                  selecionado: _filtroDisponivel == true,
                  cor: const Color(0xFF10B981),
                  onTap: () => setState(() => _filtroDisponivel = true),
                ),
                const SizedBox(width: 8),
                _FiltroChip(
                  label: 'Indisponíveis',
                  selecionado: _filtroDisponivel == false,
                  cor: Colors.red,
                  onTap: () => setState(() => _filtroDisponivel = false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Contador
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

          // Lista
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
              icone: Icons.inventory_2_outlined,
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: produtosFiltrados.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = produtosFiltrados[i];
                return _ProdutoTile(
                  produto: p,
                  onDelete: () =>
                      _confirmarRemocao(context, vm, p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarRemocao(
      BuildContext context, ProdutoViewModel vm, Produto p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover produto',
            style: TextStyle(color: Colors.white)),
        content: Text('Deseja remover "${p.nome}"?',
            style: const TextStyle(color: Color(0xFF9CA3AF))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          TextButton(
            onPressed: () {
              vm.removerProduto(p.id);
              Navigator.pop(context);
            },
            child:
            const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProdutoTile extends StatelessWidget {
  final Produto produto;
  final VoidCallback onDelete;

  const _ProdutoTile({required this.produto, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final margem = produto.precoVenda > 0 && produto.precoCusto > 0
        ? ((produto.precoVenda - produto.precoCusto) /
        produto.precoVenda *
        100)
        .toStringAsFixed(1)
        : null;

    return Container(
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
                      produto.disponivel ? 'Disponível' : 'Indisponível',
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

          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Color(0xFF9CA3AF), size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

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
                color: cor, fontSize: 13, fontWeight: FontWeight.w600)),
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
          color: selecionado ? cor.withOpacity(0.15) : const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selecionado ? cor : const Color(0xFF3A3A4E),
          ),
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
  final IconData icone;
  const _Vazio({required this.mensagem, required this.icone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, color: const Color(0xFF3A3A4E), size: 64),
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