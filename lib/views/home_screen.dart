import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/pedido_viewmodel.dart';
import '../viewmodels/cliente_viewmodel.dart';
import '../viewmodels/produto_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PedidoViewModel>().carregarPedidos();
      context.read<ClienteViewModel>().carregarClientes();
      context.read<ProdutoViewModel>().carregarProdutos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pedidoVm = context.watch<PedidoViewModel>();
    final clienteVm = context.watch<ClienteViewModel>();
    final produtoVm = context.watch<ProdutoViewModel>();

    final totalVendas = pedidoVm.pedidos
        .where((p) => p.status == 'concluido')
        .fold(0.0, (sum, p) => sum + p.total);

    final pedidosPendentes =
        pedidoVm.pedidos.where((p) => p.status == 'pendente').length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_saudacao(),
                          style: const TextStyle(
                              color: Color(0xFF9CA3AF), fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        FirebaseAuth.instance.currentUser?.displayName ??
                            'Usuário',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<AuthViewModel>().logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.logout,
                          color: Color(0xFF9CA3AF), size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9C6FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total em Vendas',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${totalVendas.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      const Icon(Icons.check_circle_outline,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                          '${pedidoVm.pedidos.where((p) => p.status == "concluido").length} pedidos concluídos',
                          style: const TextStyle(color: Colors.white70)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: _CardResumo(
                    label: 'Pendentes',
                    valor: '$pedidosPendentes',
                    icone: Icons.pending_actions,
                    cor: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CardResumo(
                    label: 'Clientes',
                    valor: '${clienteVm.clientes.length}',
                    icone: Icons.people_outline,
                    cor: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CardResumo(
                    label: 'Produtos',
                    valor: '${produtoVm.produtos.length}',
                    icone: Icons.inventory_2_outlined,
                    cor: const Color(0xFF3B82F6),
                  ),
                ),
              ]),
              const SizedBox(height: 32),
              const Text('Ações rápidas',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _CardAtalho(
                    label: 'Novo Pedido',
                    icone: Icons.add_shopping_cart,
                    cor: const Color(0xFF6C63FF),
                      onTap: () => Navigator.pushNamed(context, '/novo-pedido'),
                  ),
                  _CardAtalho(
                    label: 'Novo Cliente',
                    icone: Icons.people_outline,
                    cor: const Color(0xFF10B981),
                      onTap: () => Navigator.pushNamed(context, '/adicionar-cliente'),
                  ),
                  _CardAtalho(
                    label: 'Novo Produto',
                    icone: Icons.add_box_outlined,
                    cor: const Color(0xFF3B82F6),
                    onTap: () => Navigator.pushNamed(context, '/adicionar-produto'),
                  ),
                  _CardAtalho(
                    label: 'Pedidos',
                    icone: Icons.receipt_long_outlined,
                    cor: const Color(0xFFF59E0B),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _saudacao() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Bom dia 👋';
    if (hora < 18) return 'Boa tarde 👋';
    return 'Boa noite 👋';
  }
}

class _CardResumo extends StatelessWidget {
  final String label, valor;
  final IconData icone;
  final Color cor;

  const _CardResumo({
    required this.label,
    required this.valor,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor, size: 22),
          const SizedBox(height: 8),
          Text(valor,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
        ],
      ),
    );
  }
}

class _CardAtalho extends StatelessWidget {
  final String label;
  final IconData icone;
  final Color cor;
  final VoidCallback onTap;

  const _CardAtalho({
    required this.label,
    required this.icone,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: cor, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: cor, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
