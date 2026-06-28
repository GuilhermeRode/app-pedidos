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
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ClienteViewModel>().carregarClientes());
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Clientes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _buscaController,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _busca = v),
              decoration: InputDecoration(
                hintText: 'Buscar cliente por nome...',
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
                  borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                ),
              ),
            ),
          ),

          // Contador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${clientesFiltrados.length} cliente(s)',
                  style: const TextStyle(
                      color: Color(0xFF9CA3AF), fontSize: 13),
                ),
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
                : clientesFiltrados.isEmpty
                ? _Vazio(
              mensagem: _busca.isNotEmpty
                  ? 'Nenhum cliente encontrado para "$_busca"'
                  : 'Nenhum cliente cadastrado ainda.',
              icone: Icons.people_outline,
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: clientesFiltrados.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final c = clientesFiltrados[i];
                return _ClienteTile(
                  cliente: c,
                  onDelete: () =>
                      _confirmarRemocao(context, vm, c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarRemocao(
      BuildContext context, ClienteViewModel vm, Cliente c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover cliente',
            style: TextStyle(color: Colors.white)),
        content: Text('Deseja remover "${c.nome}"?',
            style: const TextStyle(color: Color(0xFF9CA3AF))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          TextButton(
            onPressed: () {
              vm.removerCliente(c.id);
              Navigator.pop(context);
            },
            child: const Text('Remover',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ClienteTile extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onDelete;

  const _ClienteTile({required this.cliente, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Row(
                  children: [
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
                  ],
                ),
                if (cliente.celular.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.phone_outlined,
                        color: Color(0xFF9CA3AF), size: 13),
                    const SizedBox(width: 4),
                    Text(cliente.celular,
                        style: const TextStyle(
                            color: Color(0xFF9CA3AF), fontSize: 13)),
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
                              color: Color(0xFF9CA3AF), fontSize: 13)),
                    ),
                  ]),
                ],
              ],
            ),
          ),

          // Botão remover
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