import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/produto.dart';
import '../viewmodels/produto_viewmodel.dart';
import '../utils/imagem_url_utils.dart';

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
  final _imagemUrlController  = TextEditingController();

  late Produto _produtoOriginal;
  bool _disponivel = true;
  bool _iniciado   = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _imagemUrlController.addListener(_normalizarUrlColada);
  }

  /// Se o texto colado for um link de compartilhamento do Google Drive,
  /// substitui automaticamente pelo link direto da imagem.
  void _normalizarUrlColada() {
    final atual = _imagemUrlController.text;
    final normalizada = normalizarUrlImagem(atual);
    if (normalizada != atual) {
      _imagemUrlController.value = TextEditingValue(
        text: normalizada,
        selection: TextSelection.collapsed(offset: normalizada.length),
      );
    }
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
      _imagemUrlController.text  = _produtoOriginal.imagemUrl ?? '';
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
    _imagemUrlController.removeListener(_normalizarUrlColada);
    _imagemUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProdutoViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF15181F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar Produto',
            style: TextStyle(
                color: Color(0xFF15181F), fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF3CA4EB),
          labelColor: const Color(0xFF3CA4EB),
          unselectedLabelColor: const Color(0xFF64748B),
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
                // Preview da foto pela URL
                Center(
                  child: ValueListenableBuilder(
                    valueListenable: _imagemUrlController,
                    builder: (_, __, ___) {
                      final url = _imagemUrlController.text.trim();
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF3CA4EB), width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: url.isEmpty
                            ? const Icon(Icons.image_outlined,
                                color: Color(0xFF64748B), size: 40)
                            : Image.network(
                                url,
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
                                    color: Color(0xFFEF4444),
                                    size: 32),
                              ),
                      );
                    },
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
                    controller: _imagemUrlController,
                    label: 'URL da foto do produto',
                    icone: Icons.link,
                    teclado: TextInputType.url,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Links do Google Drive são convertidos automaticamente.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
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
                            color: Color(0xFF64748B), fontSize: 12),
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
                                  color: Color(0xFF15181F),
                                  fontWeight: FontWeight.w600)),
                          Text('Desabilite para deixar indisponível',
                              style: TextStyle(
                                  color: Color(0xFF64748B),
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
                  color: const Color(0xFF3CA4EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF3CA4EB).withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline,
                      color: Color(0xFF3CA4EB), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'O estoque será atualizado automaticamente a cada pedido concluído.',
                      style: TextStyle(
                          color: Color(0xFF64748B), fontSize: 13),
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
                  backgroundColor: const Color(0xFF3CA4EB),
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

    final urlDigitada = _imagemUrlController.text.trim();

    final produtoAtualizado = _produtoOriginal.copyWith(
      nome: _nomeController.text.trim(),
      precoVenda: precoVenda,
      precoCusto: precoCusto,
      disponivel: _disponivel,
      imagemUrl: urlDigitada.isEmpty ? null : urlDigitada,
      limparImagem: urlDigitada.isEmpty,
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
                color: Color(0xFF15181F),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
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
      style: const TextStyle(color: Color(0xFF15181F)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        const TextStyle(color: Color(0xFF64748B)),
        prefixIcon:
        Icon(icone, color: const Color(0xFF3CA4EB), size: 20),
        filled: true,
        fillColor: const Color(0xFFF0F4F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE1E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3CA4EB)),
        ),
      ),
    );
  }
}
