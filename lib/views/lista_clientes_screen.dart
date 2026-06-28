import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cliente.dart';
import '../viewmodels/cliente_viewmodel.dart';

class ListaClientesScreen extends StatefulWidget {
  const ListaClientesScreen({super.key});

  @override
  State<ListaClientesScreen> createState() => _ListaClientesScreenState();
}

class _ListaClientesScreenState extends State<ListaClientesScreen> {
  final _buscaController = TextEditingController();
  String _busca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClienteViewModel>();

    final clientesFiltrados = vm.clientes
        .where((c) => c.nome.toLowerCase().contains(_busca.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Clientes',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // ── Busca ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _buscaController,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _busca = v),
              decoration: InputDecoration(
                hintText: 'Buscar cliente por nome...',
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

          // ── Contador ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${clientesFiltrados.length} cliente(s)',
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
                : clientesFiltrados.isEmpty
                ? _Vazio(
              mensagem: _busca.isNotEmpty
                  ? 'Nenhum cliente encontrado para "$_busca"'
                  : 'Nenhum cliente cadastrado ainda.',
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: clientesFiltrados.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final c = clientesFiltrados[i];
                return _ClienteCard(
                  cliente: c,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/detalhes-cliente',
                    arguments: c,
                  ).then((_) => context
                      .read<ClienteViewModel>()
                      .carregarClientes()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card clicável — sem lixeira ───────────────────────────────────────────────

class _ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onTap;

  const _ClienteCard({required this.cliente, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
            // Avatar com inicial
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.4)),
              ),
              child: Center(
                child: Text(
                  cliente.nome.isNotEmpty
                      ? cliente.nome[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Dados
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(cliente.nome,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cliente.ativo
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cliente.ativo ? 'Ativo' : 'Inativo',
                        style: TextStyle(
                          color: cliente.ativo
                              ? const Color(0xFF10B981)
                              : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ]),
                  if (cliente.celular.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.phone_outlined,
                          color: Color(0xFF9CA3AF), size: 13),
                      const SizedBox(width: 4),
                      Text(cliente.celular,
                          style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 13)),
                    ]),
                  ],
                  if (cliente.email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.email_outlined,
                          color: Color(0xFF9CA3AF), size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(cliente.email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 13)),
                      ),
                    ]),
                  ],
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

class _Vazio extends StatelessWidget {
  final String mensagem;
  const _Vazio({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline,
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