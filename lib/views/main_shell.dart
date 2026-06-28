import 'package:flutter/material.dart';
import 'package:pedido_app/views/home_screen.dart';
import 'package:pedido_app/views/lista_clientes_screen.dart';
import 'package:pedido_app/views/lista_pedidos_screen.dart';
import 'package:pedido_app/views/lista_produtos_screen.dart';

import 'package:provider/provider.dart';

import '../viewmodels/cliente_viewmodel.dart';
import '../viewmodels/pedido_viewmodel.dart';
import '../viewmodels/produto_viewmodel.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _telas = const [
    HomeScreen(),
    ListaPedidosScreen(),
    ListaClientesScreen(),
    ListaProdutosScreen(),
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

  //=========================================================
  // FAB muda conforme a tela atual
  //=========================================================

  void _fabAction() {
    switch (_currentIndex) {
    // HOME
      case 0:
        Navigator.pushNamed(context, '/novo-pedido').then((_) {
          context.read<PedidoViewModel>().carregarPedidos();
        });
        break;

    // PEDIDOS
      case 1:
        Navigator.pushNamed(context, '/novo-pedido').then((_) {
          context.read<PedidoViewModel>().carregarPedidos();
        });
        break;

    // CLIENTES
      case 2:
        Navigator.pushNamed(context, '/adicionar-cliente').then((_) {
          context.read<ClienteViewModel>().carregarClientes();
        });
        break;

    // PRODUTOS
      case 3:
        Navigator.pushNamed(context, '/adicionar-produto').then((_) {
          context.read<ProdutoViewModel>().carregarProdutos();
        });
        break;
    }
  }

  IconData _fabIcon() {
    switch (_currentIndex) {
      case 0:
      case 1:
        return Icons.receipt_long_rounded;

      case 2:
        return Icons.person_add_alt_1_rounded;

      case 3:
        return Icons.inventory_2_rounded;

      default:
        return Icons.add;
    }
  }

  String _fabTooltip() {
    switch (_currentIndex) {
      case 0:
      case 1:
        return 'Novo Pedido';

      case 2:
        return 'Novo Cliente';

      case 3:
        return 'Novo Produto';

      default:
        return 'Adicionar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      body: IndexedStack(
        index: _currentIndex,
        children: _telas,
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: _fabTooltip(),
        onPressed: _fabAction,
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 4,
        shape: const CircleBorder(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Icon(
            _fabIcon(),
            key: ValueKey(_currentIndex),
            color: Colors.white,
            size: 28,
          ),
        ),
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

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

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

            const SizedBox(width: 72),

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