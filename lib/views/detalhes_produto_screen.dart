import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/produto.dart';
import '../viewmodels/produto_viewmodel.dart';

class DetalhesProdutoScreen extends StatelessWidget {
  const DetalhesProdutoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final produto =
    ModalRoute.of(context)!.settings.arguments as Produto;

    final temMargem =
        produto.precoVenda > 0 && produto.precoCusto > 0;
    final margem = temMargem
        ? (produto.precoVenda - produto.precoCusto) /
        produto.precoVenda *
        100
        : 0.0;
    final lucro = produto.precoVenda - produto.precoCusto;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF15181F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detalhes do Produto',
            style: TextStyle(
                color: Color(0xFF15181F), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmarExclusao(context, produto),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Ícone + nome + badge ────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color:
                          const Color(0xFF3B82F6).withOpacity(0.4),
                          width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: (produto.imagemUrl == null ||
                            produto.imagemUrl!.isEmpty)
                        ? const Icon(Icons.inventory_2_outlined,
                            color: Color(0xFF3B82F6), size: 36)
                        : Image.network(
                            produto.imagemUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF3CA4EB)),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF3B82F6),
                                size: 32),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(produto.nome,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFF15181F),
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
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
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Preços ──────────────────────────────────────────────────
            _Secao(titulo: 'Preços', children: [
              Row(children: [
                Expanded(
                  child: _CardPreco(
                    label: 'Preço de Venda',
                    valor:
                    'R\$ ${produto.precoVenda.toStringAsFixed(2)}',
                    cor: const Color(0xFF10B981),
                    icone: Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CardPreco(
                    label: 'Preço de Custo',
                    valor:
                    'R\$ ${produto.precoCusto.toStringAsFixed(2)}',
                    cor: const Color(0xFF64748B),
                    icone: Icons.money_off,
                  ),
                ),
              ]),
              if (temMargem) ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF0F4F9)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: _CardPreco(
                      label: 'Lucro por Unid.',
                      valor: 'R\$ ${lucro.toStringAsFixed(2)}',
                      cor: const Color(0xFF3CA4EB),
                      icone: Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CardPreco(
                      label: 'Margem',
                      valor: '${margem.toStringAsFixed(1)}%',
                      cor: const Color(0xFFF59E0B),
                      icone: Icons.percent,
                    ),
                  ),
                ]),
              ],
            ]),

            const SizedBox(height: 32),

            // ── Botão editar ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/editar-produto',
                  arguments: produto,
                ).then((_) => Navigator.pop(context)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3CA4EB),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.white),
                label: const Text(
                  'Editar Produto',
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

  void _confirmarExclusao(BuildContext context, Produto produto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir produto',
            style: TextStyle(color: Color(0xFF15181F))),
        content: Text(
            'Deseja excluir "${produto.nome}"? Esta ação não pode ser desfeita.',
            style: const TextStyle(color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<ProdutoViewModel>()
                  .removerProduto(produto.id);
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
                color: Color(0xFF15181F),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children),
        ),
      ],
    );
  }
}

class _CardPreco extends StatelessWidget {
  final String label, valor;
  final Color cor;
  final IconData icone;

  const _CardPreco({
    required this.label,
    required this.valor,
    required this.cor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor, size: 18),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B), fontSize: 11)),
          const SizedBox(height: 4),
          Text(valor,
              style: TextStyle(
                  color: cor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}