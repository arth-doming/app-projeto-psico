import 'package:flutter/material.dart';
import '../../data/dados_locais.dart';
import '../../models/paciente.dart';
import 'paciente_detalhe_screen.dart';
import 'paciente_form_screen.dart';

class PacientesScreen extends StatefulWidget {
  const PacientesScreen({super.key});

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  String _busca = '';
  late List<Paciente> _pacientes;

  @override
  void initState() {
    super.initState();
    _pacientes = List.from(pacientesLocais);
  }

  List<Paciente> get _pacientesFiltrados => _pacientes
      .where((p) => p.nome.toLowerCase().contains(_busca.toLowerCase()))
      .toList();

  Color _corAvatar(String iniciais) {
    final cores = [
      const Color(0xFF7C6FCD),
      const Color(0xFF4CAADC),
      const Color(0xFFE67E7E),
      const Color(0xFF67B99A),
    ];
    return cores[iniciais.codeUnitAt(0) % cores.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _busca = v),
              decoration: InputDecoration(
                hintText: 'Buscar paciente...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: _pacientesFiltrados.isEmpty
                ? Center(
                    child: Text('Nenhum paciente encontrado',
                        style: TextStyle(color: Colors.grey[400])))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _pacientesFiltrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final p = _pacientesFiltrados[i];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: _corAvatar(p.iniciais),
                            child: Text(
                              p.iniciais,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(p.nome,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text('${p.idade} anos • ${p.telefone}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    PacienteDetalheScreen(paciente: p)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final novo = await Navigator.push<Paciente>(
            context,
            MaterialPageRoute(
              builder: (_) => const PacienteFormScreen()),
          );
          if (novo != null) setState(() => _pacientes.add(novo));
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
