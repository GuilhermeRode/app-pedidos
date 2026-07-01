import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/produto.dart';
import '../viewmodels/produto_viewmodel.dart';

class EditarProdutoScreen extends StatefulWidget {
  const EditarProdutoScreen({super.key});

  @override
  State<EditarProdutoScreen> createState() => _EditarProdutoScreenState();
}

class _EditarProdutoScreenState extends State<EditarProdutoScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final _nomeController       = TextEditingController();
  final _precoVendaController = TextEditingController();
  final _precoCustoController = TextEditingController();
  final _estoqueController    = TextEditingController();

  late Produto _produtoOriginal;
  bool _disponivel = true;
  bool _iniciado   = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iniciado) {
      _produtoOriginal =
      ModalRoute.of(context)!.settings.arguments as Produto;

      _nomeController.text       = _produtoOriginal.nome;
      _precoVendaController.text = _produtoOriginal.precoVenda > 0
          ? _produtoOriginal.precoVenda.toStringAsFixed(2)
          : '';
      _precoCustoController.text = _produtoOriginal.precoCusto > 0
          ? _produtoOriginal.precoCusto.toStringAsFixed(2)
          : '';
      _disponivel = _produtoOriginal.disponivel;

      _iniciado = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _precoVendaController.dispose();
    _precoCustoController.dispose();
    _estoqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProdutoViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar Produto',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6C63FF),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF9CA3AF),
          tabs: const [
            Tab(text: 'Item'),
            Tab(text: 'Estoque'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Aba Item ──────────────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem placeholder
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF6C63FF), width: 2),
                        ),
                        child: const Icon(Icons.image_outlined,
                            color: Color(0xFF9CA3AF), size: 40),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6C63FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _Secao(titulo: 'Informações', children: [
                  _Campo(
                      controller: _nomeController,
                      label: 'Nome *',
                      icone: Icons.label_outline),
                  const SizedBox(height: 16),

                  _Campo(
                    controller: _precoVendaController,
                    label: 'Preço de Venda',
                    icone: Icons.attach_money,
                    teclado: const TextInputType.numberWithOptions(
                        decimal: true),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),

                  // Markup dinâmico
                  ValueListenableBuilder(
                    valueListenable: _precoVendaController,
                    builder: (_, __, ___) {
                      final venda = double.tryParse(
                          _precoVendaController.text
                              .replaceAll(',', '.')) ??
                          0;
                      final custo = double.tryParse(
                          _precoCustoController.text
                              .replaceAll(',', '.')) ??
                          0;
                      final margem = venda > 0
                          ? ((venda - custo) / venda * 100)
                          .toStringAsFixed(1)
                          : '0';
                      return Text(
                        'Margem: $margem%   Lucro: R\$ ${(venda - custo).toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Color(0xFF9CA3AF), fontSize: 12),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  _Campo(
                    controller: _precoCustoController,
                    label: 'Preço de Custo',
                    icone: Icons.money_off,
                    teclado: const TextInputType.numberWithOptions(
                        decimal: true),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  // Toggle disponível
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Disponível',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          Text('Desabilite para deixar indisponível',
                              style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12)),
                        ],
                      ),
                      Switch(
                        value: _disponivel,
                        activeColor: const Color(0xFF10B981),
                        onChanged: (v) =>
                            setState(() => _disponivel = v),
                      ),
                    ],
                  ),
                ]),
              ],
            ),
          ),

          // ── Aba Estoque ───────────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _Secao(titulo: 'Controle de Estoque', children: [
              _Campo(
                controller: _estoqueController,
                label: 'Quantidade em Estoque',
                icone: Icons.inventory_2_outlined,
                teclado: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline,
                      color: Color(0xFF6C63FF), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'O estoque será atualizado automaticamente a cada pedido concluído.',
                      style: TextStyle(
                          color: Color(0xFF9CA3AF), fontSize: 13),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ],
      ),

      // ── Botão salvar fixo no bottom ───────────────────────────────────
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vm.erro != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(vm.erro!,
                      style: const TextStyle(color: Colors.red)),
                ]),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: vm.carregando ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: vm.carregando
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check, color: Colors.white),
                label: Text(
                  vm.carregando ? 'Salvando...' : 'Salvar Alterações',
                  style: const TextStyle(
                      fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _salvar() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome é obrigatório.')),
      );
      return;
    }

    final precoVenda = double.tryParse(
        _precoVendaController.text.replaceAll(',', '.')) ??
        0;
    final precoCusto = double.tryParse(
        _precoCustoController.text.replaceAll(',', '.')) ??
        0;

    final produtoAtualizado = _produtoOriginal.copyWith(
      nome: _nomeController.text.trim(),
      precoVenda: precoVenda,
      precoCusto: precoCusto,
      disponivel: _disponivel,
    );

    final ok = await context
        .read<ProdutoViewModel>()
        .atualizarProduto(produtoAtualizado);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto atualizado com sucesso!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
    }
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
        const SizedBox(height: 16),
        Container(
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

class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icone;
  final bool obscuro;
  final TextInputType? teclado;
  final ValueChanged<String>? onChanged;

  const _Campo({
    required this.controller,
    required this.label,
    required this.icone,
    this.obscuro = false,
    this.teclado,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscuro,
      keyboardType: teclado,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        const TextStyle(color: Color(0xFF9CA3AF)),
        prefixIcon:
        Icon(icone, color: const Color(0xFF6C63FF), size: 20),
        filled: true,
        fillColor: const Color(0xFF2A2A3E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
      ),
    );
  }
}