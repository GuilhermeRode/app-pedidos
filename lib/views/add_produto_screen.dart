import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../models/cliente.dart';
import '../models/produto.dart';
import '../viewmodels/pedido_viewmodel.dart';
import '../viewmodels/produto_viewmodel.dart';
import '../viewmodels/cliente_viewmodel.dart';

class AdicionarProdutoScreen extends StatefulWidget {
  const AdicionarProdutoScreen({super.key});

  @override
  State<AdicionarProdutoScreen> createState() => _AdicionarProdutoScreenState();
}

class _AdicionarProdutoScreenState extends State<AdicionarProdutoScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final _nomeController       = TextEditingController();
  final _precoVendaController = TextEditingController();
  final _precoCustoController = TextEditingController();
  final _estoqueController    = TextEditingController();

  bool _disponivel = true;
  String _tipoSelecionado = 'Produto'; // Produto, Combo, Serviço

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Adicionar Produto',
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
          // Aba 1 - Item
          _AbaItem(
            nomeController: _nomeController,
            precoVendaController: _precoVendaController,
            precoCustoController: _precoCustoController,
            disponivel: _disponivel,
            tipoSelecionado: _tipoSelecionado,
            onDisponivel: (v) => setState(() => _disponivel = v),
            onTipo: (t) => setState(() => _tipoSelecionado = t),
          ),

          // Aba 2 - Estoque
          _AbaEstoque(estoqueController: _estoqueController),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: vm.carregando ? null : _salvar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: vm.carregando
                ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check, color: Colors.white),
            label: Text(
              vm.carregando ? 'Salvando...' : 'Salvar',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
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
        _precoVendaController.text.replaceAll(',', '.')) ?? 0;
    final precoCusto = double.tryParse(
        _precoCustoController.text.replaceAll(',', '.')) ?? 0;

    final produto = Produto(
      id: '',
      nome: _nomeController.text.trim(),
      precoVenda: precoVenda,
      precoCusto: precoCusto,
      disponivel: _disponivel,
    );

    final ok = await context.read<ProdutoViewModel>().adicionarProduto(produto);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto adicionado com sucesso!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
    }
  }
}

// Aba Item
class _AbaItem extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController precoVendaController;
  final TextEditingController precoCustoController;
  final bool disponivel;
  final String tipoSelecionado;
  final ValueChanged<bool> onDisponivel;
  final ValueChanged<String> onTipo;

  const _AbaItem({
    required this.nomeController,
    required this.precoVendaController,
    required this.precoCustoController,
    required this.disponivel,
    required this.tipoSelecionado,
    required this.onDisponivel,
    required this.onTipo,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Seletor de tipo
          Row(children: ['Produto', 'Combo', 'Serviço'].map((tipo) {
            final selecionado = tipoSelecionado == tipo;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onTipo(tipo),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selecionado
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selecionado
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF3A3A4E),
                    ),
                  ),
                  child: Text(tipo,
                      style: TextStyle(
                          color: selecionado
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                          fontWeight: selecionado
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ),
              ),
            );
          }).toList()),

          const SizedBox(height: 24),

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
                  bottom: 0, right: 0,
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

          // Campos
          _Secao(titulo: 'Informações', children: [
            _Campo(controller: nomeController,
                label: 'Nome *', icone: Icons.label_outline),
            const SizedBox(height: 16),

            // Preço de venda
            _Campo(
              controller: precoVendaController,
              label: 'Preço de Venda',
              icone: Icons.attach_money,
              teclado: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),

            // Markup calculado dinamicamente
            ValueListenableBuilder(
              valueListenable: precoVendaController,
              builder: (_, __, ___) {
                return ValueListenableBuilder(
                  valueListenable: precoVendaController,
                  builder: (_, __, ___) {
                    final venda = double.tryParse(
                        precoVendaController.text.replaceAll(',', '.')) ?? 0;
                    return Text(
                      'Markup: 0%   Margem de Lucro: 0% (R\$ ${venda.toStringAsFixed(2)})',
                      style: const TextStyle(
                          color: Color(0xFF9CA3AF), fontSize: 12),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            _Campo(
              controller: precoCustoController,
              label: 'Preço de Custo',
              icone: Icons.money_off,
              teclado: const TextInputType.numberWithOptions(decimal: true),
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
                            color: Color(0xFF9CA3AF), fontSize: 12)),
                  ],
                ),
                Switch(
                  value: disponivel,
                  activeColor: const Color(0xFF10B981),
                  onChanged: onDisponivel,
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}

// Aba Estoque
class _AbaEstoque extends StatelessWidget {
  final TextEditingController estoqueController;
  const _AbaEstoque({required this.estoqueController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _Secao(titulo: 'Controle de Estoque', children: [
        _Campo(
          controller: estoqueController,
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
    );
  }
}

// Widgets auxiliares reutilizáveis
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

  const _Campo({
    required this.controller,
    required this.label,
    required this.icone,
    this.obscuro = false,
    this.teclado,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscuro,
      keyboardType: teclado,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        prefixIcon: Icon(icone, color: const Color(0xFF6C63FF), size: 20),
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