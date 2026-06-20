import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cliente.dart';
import '../viewmodels/cliente_viewmodel.dart';

class AdicionarClienteScreen extends StatefulWidget {
  const AdicionarClienteScreen({super.key});

  @override
  State<AdicionarClienteScreen> createState() => _AdicionarClienteScreenState();
}

class _AdicionarClienteScreenState extends State<AdicionarClienteScreen> {
  final _nomeController        = TextEditingController();
  final _celularController     = TextEditingController();
  final _emailController       = TextEditingController();
  final _codigoController      = TextEditingController();
  final _cepController         = TextEditingController();
  final _enderecoController    = TextEditingController();
  final _numeroController      = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController      = TextEditingController();
  final _cidadeController      = TextEditingController();
  final _estadoController      = TextEditingController();

  bool _ativo = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _celularController.dispose();
    _emailController.dispose();
    _codigoController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClienteViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Adicionar Cliente',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Seção: Dados principais
            _Secao(titulo: 'Dados Principais', children: [

              // Toggle ativo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Está Ativo?',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Switch(
                    value: _ativo,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) => setState(() => _ativo = v),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _Campo(controller: _nomeController,
                  label: 'Nome *', icone: Icons.person_outline),
              const SizedBox(height: 16),

              _Campo(controller: _codigoController,
                  label: 'Código', icone: Icons.tag),
              const SizedBox(height: 16),

              // Celular com prefixo +55
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(children: [
                    Text('🇧🇷', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 6),
                    Text('+55',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Campo(
                    controller: _celularController,
                    label: 'Celular',
                    icone: Icons.phone_outlined,
                    teclado: TextInputType.phone,
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              _Campo(controller: _emailController,
                  label: 'E-mail', icone: Icons.email_outlined,
                  teclado: TextInputType.emailAddress),
            ]),

            const SizedBox(height: 24),

            // Seção: Endereço
            _Secao(titulo: 'Endereço', children: [

              _Campo(controller: _cepController,
                  label: 'Código Postal', icone: Icons.location_on_outlined,
                  teclado: TextInputType.number),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(
                  flex: 2,
                  child: _Campo(controller: _enderecoController,
                      label: 'Endereço', icone: Icons.home_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Campo(controller: _numeroController,
                      label: 'Número', icone: Icons.numbers,
                      teclado: TextInputType.number),
                ),
              ]),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(
                  child: _Campo(controller: _complementoController,
                      label: 'Complemento', icone: Icons.apartment),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Campo(controller: _bairroController,
                      label: 'Bairro', icone: Icons.map_outlined),
                ),
              ]),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(
                  flex: 2,
                  child: _Campo(controller: _cidadeController,
                      label: 'Cidade', icone: Icons.location_city),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Campo(controller: _estadoController,
                      label: 'Estado', icone: Icons.flag_outlined),
                ),
              ]),
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
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(vm.erro!,
                      style: const TextStyle(color: Colors.red)),
                ]),
              ),

            // Botão salvar
            SizedBox(
              width: double.infinity,
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
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome é obrigatório.')),
      );
      return;
    }

    final cliente = Cliente(
      id: '',
      nome: _nomeController.text.trim(),
      celular: _celularController.text.trim(),
      email: _emailController.text.trim(),
      ativo: _ativo,
    );

    final ok = await context.read<ClienteViewModel>().adicionarCliente(cliente);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente adicionado com sucesso!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
    }
  }
}

// Seção com título e borda
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
            children: children,
          ),
        ),
      ],
    );
  }
}

// Campo de texto reutilizável
class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icone;
  final bool obscuro;
  final TextInputType? teclado;
  final Widget? sufixo;

  const _Campo({
    required this.controller,
    required this.label,
    required this.icone,
    this.obscuro = false,
    this.teclado,
    this.sufixo,
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
        suffixIcon: sufixo,
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