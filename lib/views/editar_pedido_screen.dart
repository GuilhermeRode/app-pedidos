import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../models/cliente.dart';
import '../models/produto.dart';
import '../viewmodels/pedido_viewmodel.dart';
import '../viewmodels/produto_viewmodel.dart';
import '../viewmodels/cliente_viewmodel.dart';

class EditarPedidoScreen extends StatefulWidget {
  const EditarPedidoScreen({super.key});

  @override
  State<EditarPedidoScreen> createState() => _EditarPedidoScreenState();
}

class _EditarPedidoScreenState extends State<EditarPedidoScreen> {
  final _descontoController   = TextEditingController();
  final _observacaoController = TextEditingController();

  // Pedido original recebido via arguments
  late Pedido _pedidoOriginal;
  bool _iniciado = false;

  Cliente? _clienteSelecionado;
  List<ItemPedido> _itens = [];
  bool _orcamento = false;
  DateTime _dataSelecionada = DateTime.now();

  double get _subtotal =>
      _itens.fold(0, (sum, item) => sum + item.subtotal);

  double get _desconto =>
      double.tryParse(_descontoController.text.replaceAll(',', '.')) ?? 0;

  double get _total => _subtotal - _desconto;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializa os campos com os dados do pedido original — só uma vez
    if (!_iniciado) {
      _pedidoOriginal =
      ModalRoute.of(context)!.settings.arguments as Pedido;

      _itens = List.from(_pedidoOriginal.itens);
      _dataSelecionada = _pedidoOriginal.data;
      _orcamento = _pedidoOriginal.status == 'orcamento';
      _descontoController.text = _pedidoOriginal.desconto > 0
          ? _pedidoOriginal.desconto.toStringAsFixed(2)
          : '';

      // Pré-seleciona o cliente pelo id
      final clienteVm = context.read<ClienteViewModel>();
      _clienteSelecionado = clienteVm.clientes.firstWhere(
            (c) => c.id == _pedidoOriginal.clienteId,
        orElse: () => Cliente(
          id: _pedidoOriginal.clienteId,
          nome: _pedidoOriginal.nomeCliente,
          celular: '',
          email: '',
          ativo: true,
        ),
      );

      _iniciado = true;
    }
  }

  @override
  void dispose() {
    _descontoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm        = context.watch<PedidoViewModel>();
    final clienteVm = context.watch<ClienteViewModel>();
    final produtoVm = context.watch<ProdutoViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar Pedido',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Dados do Pedido ─────────────────────────────────────────
            _Secao(titulo: 'Dados do Pedido', children: [

              // Data
              GestureDetector(
                onTap: () => _selecionarData(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Data',
                              style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '${_dataSelecionada.day.toString().padLeft(2, '0')}/'
                                '${_dataSelecionada.month.toString().padLeft(2, '0')}/'
                                '${_dataSelecionada.year}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_today,
                          color: Color(0xFF6C63FF), size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Seleção de cliente
              GestureDetector(
                onTap: () =>
                    _selecionarCliente(context, clienteVm.clientes),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.person_outline,
                            color: Color(0xFF6C63FF), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _clienteSelecionado?.nome ??
                              'Selecionar Cliente',
                          style: TextStyle(
                            color: _clienteSelecionado != null
                                ? Colors.white
                                : const Color(0xFF9CA3AF),
                            fontSize: 16,
                          ),
                        ),
                      ]),
                      const Icon(Icons.chevron_right,
                          color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Toggle orçamento
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Orçamento',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16)),
                  Switch(
                    value: _orcamento,
                    activeColor: const Color(0xFF6C63FF),
                    onChanged: (v) => setState(() => _orcamento = v),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 24),

            // ── Itens ───────────────────────────────────────────────────
            _Secao(titulo: 'Itens', children: [
              GestureDetector(
                onTap: () =>
                    _adicionarProduto(context, produtoVm.produtos),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      const Text('Adicionar Produto',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                    ]),
                    const Icon(Icons.qr_code_scanner,
                        color: Color(0xFF9CA3AF)),
                  ],
                ),
              ),
              if (_itens.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF3A3A4E)),
                ..._itens.map((item) => _ItemPedidoTile(
                  item: item,
                  onRemover: () =>
                      setState(() => _itens.remove(item)),
                  onAlterarQtd: (qtd) => setState(() {
                    final index = _itens.indexOf(item);
                    _itens[index] = ItemPedido(
                      produtoId: item.produtoId,
                      nomeProduto: item.nomeProduto,
                      quantidade: qtd,
                      precoUnitario: item.precoUnitario,
                    );
                  }),
                )),
              ],
            ]),

            const SizedBox(height: 24),

            // ── Resumo ──────────────────────────────────────────────────
            _Secao(titulo: 'Resumo', children: [
              _LinhaResumo(
                label: '${_itens.length} item(s)',
                valor: 'Subtotal: R\$ ${_subtotal.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 16),
              _CampoResumo(
                icone: Icons.local_offer_outlined,
                label: 'Dar Desconto',
                controller: _descontoController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF3A3A4E)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(
                    'R\$ ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 24),

            // ── Observação ──────────────────────────────────────────────
            _Secao(titulo: 'Observação', children: [
              TextField(
                controller: _observacaoController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Adicione uma observação...',
                  hintStyle:
                  const TextStyle(color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3E),
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
            ]),

            const SizedBox(height: 32),

            // Erro
            if (vm.erro != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
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

            // ── Botão salvar ────────────────────────────────────────────
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _salvar() async {
    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente.')),
      );
      return;
    }
    if (_itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Adicione pelo menos um produto.')),
      );
      return;
    }

    // Usa copyWith para preservar o id e atualizar o restante
    final pedidoAtualizado = _pedidoOriginal.copyWith(
      clienteId: _clienteSelecionado!.id,
      nomeCliente: _clienteSelecionado!.nome,
      itens: _itens,
      status: _orcamento ? 'orcamento' : 'pendente',
      data: _dataSelecionada,
      desconto: _desconto,
    );

    final ok = await context
        .read<PedidoViewModel>()
        .atualizarPedido(pedidoAtualizado);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido atualizado com sucesso!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context); // volta para DetalhesPedidoScreen
    }
  }

  void _selecionarData(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            surface: Color(0xFF1E1E2E),
          ),
        ),
        child: child!,
      ),
    );
    if (data != null) setState(() => _dataSelecionada = data);
  }

  void _selecionarCliente(
      BuildContext context, List<Cliente> clientes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A4E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Selecionar Cliente',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: clientes.isEmpty
                  ? const Center(
                  child: Text('Nenhum cliente cadastrado.',
                      style: TextStyle(
                          color: Color(0xFF9CA3AF))))
                  : ListView.builder(
                controller: controller,
                itemCount: clientes.length,
                itemBuilder: (_, i) {
                  final c = clientes[i];
                  final selecionado =
                      c.id == _clienteSelecionado?.id;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF6C63FF)
                          .withOpacity(0.2),
                      child: Text(c.nome[0].toUpperCase(),
                          style: const TextStyle(
                              color: Color(0xFF6C63FF))),
                    ),
                    title: Text(c.nome,
                        style: TextStyle(
                            color: selecionado
                                ? const Color(0xFF6C63FF)
                                : Colors.white,
                            fontWeight: selecionado
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    subtitle: Text(c.celular,
                        style: const TextStyle(
                            color: Color(0xFF9CA3AF))),
                    trailing: selecionado
                        ? const Icon(Icons.check,
                        color: Color(0xFF6C63FF))
                        : null,
                    onTap: () {
                      setState(
                              () => _clienteSelecionado = c);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _adicionarProduto(
      BuildContext context, List<Produto> produtos) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A4E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Selecionar Produto',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: produtos.isEmpty
                  ? const Center(
                  child: Text('Nenhum produto cadastrado.',
                      style: TextStyle(
                          color: Color(0xFF9CA3AF))))
                  : ListView.builder(
                controller: controller,
                itemCount: produtos.length,
                itemBuilder: (_, i) {
                  final p = produtos[i];
                  final jaAdicionado = _itens
                      .any((it) => it.produtoId == p.id);
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6)
                            .withOpacity(0.2),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      child: const Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFF3B82F6),
                          size: 20),
                    ),
                    title: Text(p.nome,
                        style: const TextStyle(
                            color: Colors.white)),
                    subtitle: Text(
                      'R\$ ${p.precoVenda.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Color(0xFF10B981)),
                    ),
                    trailing: Icon(
                      jaAdicionado
                          ? Icons.add_circle
                          : Icons.add_circle_outline,
                      color: const Color(0xFF6C63FF),
                    ),
                    onTap: () {
                      setState(() {
                        final index = _itens.indexWhere(
                                (it) => it.produtoId == p.id);
                        if (index >= 0) {
                          final atual = _itens[index];
                          _itens[index] = ItemPedido(
                            produtoId: atual.produtoId,
                            nomeProduto: atual.nomeProduto,
                            quantidade: atual.quantidade + 1,
                            precoUnitario:
                            atual.precoUnitario,
                          );
                        } else {
                          _itens.add(ItemPedido(
                            produtoId: p.id,
                            nomeProduto: p.nome,
                            quantidade: 1,
                            precoUnitario: p.precoVenda,
                          ));
                        }
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares (mesmos do add_pedido_screen) ─────────────────────────

class _ItemPedidoTile extends StatelessWidget {
  final ItemPedido item;
  final VoidCallback onRemover;
  final ValueChanged<int> onAlterarQtd;

  const _ItemPedidoTile({
    required this.item,
    required this.onRemover,
    required this.onAlterarQtd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nomeProduto,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                Text(
                    'R\$ ${item.precoUnitario.toStringAsFixed(2)} un.',
                    style: const TextStyle(
                        color: Color(0xFF9CA3AF), fontSize: 12)),
              ],
            ),
          ),
          Row(children: [
            GestureDetector(
              onTap: () {
                if (item.quantidade > 1) {
                  onAlterarQtd(item.quantidade - 1);
                } else {
                  onRemover();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A4E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.remove,
                    color: Colors.white, size: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('${item.quantidade}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
            GestureDetector(
              onTap: () => onAlterarQtd(item.quantidade + 1),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.add,
                    color: Colors.white, size: 16),
              ),
            ),
          ]),
          const SizedBox(width: 12),
          Text('R\$ ${item.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _LinhaResumo extends StatelessWidget {
  final String label, valor;
  const _LinhaResumo({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF9CA3AF))),
        Text(valor,
            style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _CampoResumo extends StatelessWidget {
  final IconData icone;
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CampoResumo({
    required this.icone,
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType:
      const TextInputType.numberWithOptions(decimal: true),
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