import 'package:flutter/material.dart';
import '../../models/paciente.dart';
import '../../services/paciente_service.dart';
import 'paciente_detalhe_screen.dart';
import 'paciente_form_screen.dart';

class PacientesScreen extends StatelessWidget {
  const PacientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: StreamBuilder<List<Paciente>>(
        stream: PacienteService.listar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final pacientes = snapshot.data ?? [];
          if (pacientes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 52, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('Nenhum paciente cadastrado',
                      style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pacientes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final p = pacientes[i];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: _corAvatar(p.iniciais),
                    child: Text(p.iniciais,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(p.nome,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${p.idade} anos • ${p.telefone}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PacienteDetalheScreen(paciente: p)),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PacienteFormScreen()),
        ),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Color _corAvatar(String iniciais) {
    final cores = [
      const Color(0xFF7C6FCD),
      const Color(0xFF4CAADC),
      const Color(0xFFE67E7E),
      const Color(0xFF67B99A),
    ];
    return cores[iniciais.codeUnitAt(0) % cores.length];
  }
}