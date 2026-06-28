import 'package:flutter/material.dart';
import 'package:pedido_app/views/lista_pedidos_screen.dart';
import 'package:provider/provider.dart';

import '../viewmodels/cliente_viewmodel.dart';
import '../viewmodels/produto_viewmodel.dart';
import '../viewmodels/pedido_viewmodel.dart';

import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // As quatro abas — sem o FAB central, que é ação separada
  final List<Widget> _telas = const [
    HomeScreen(),
      ListaPedidosScreen(),
    //ListaClientesScreen(),
    //ListaProdutosScreen(),
  ];

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
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: IndexedStack(
        index: _currentIndex,
        children: _telas,
      ),

      // FAB central — abre diretamente "Novo Pedido"
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/novo-pedido')
            .then((_) => context.read<PedidoViewModel>().carregarPedidos()),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF1E1E2E),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            // Lado esquerdo: Home e Pedidos
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icone: Icons.home_outlined,
                    iconeAtivo: Icons.home_rounded,
                    label: 'Home',
                    ativo: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icone: Icons.receipt_long_outlined,
                    iconeAtivo: Icons.receipt_long_rounded,
                    label: 'Pedidos',
                    ativo: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ],
              ),
            ),

            // Espaço reservado para o FAB
            const SizedBox(width: 72),

            // Lado direito: Clientes e Produtos
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icone: Icons.people_outline,
                    iconeAtivo: Icons.people_rounded,
                    label: 'Clientes',
                    ativo: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    icone: Icons.inventory_2_outlined,
                    iconeAtivo: Icons.inventory_2_rounded,
                    label: 'Produtos',
                    ativo: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icone;
  final IconData iconeAtivo;
  final String label;
  final bool ativo;
  final VoidCallback onTap;

  const _NavItem({
    required this.icone,
    required this.iconeAtivo,
    required this.label,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cor =
    ativo ? const Color(0xFF6C63FF) : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                ativo ? iconeAtivo : icone,
                key: ValueKey(ativo),
                color: cor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: cor,
                fontSize: 11,
                fontWeight:
                ativo ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}