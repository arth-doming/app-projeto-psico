import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/consulta.dart';
import '../../models/evolucao.dart';
import '../../services/consulta_service.dart';
import '../../services/evolucao_service.dart';
import 'nova_consulta_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Consulta> _todasConsultas = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  List<Consulta> _consultasDoDia(DateTime dia) {
    return _todasConsultas
        .where((c) => isSameDay(c.dataHora, dia))
        .toList()
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));
  }

  Color _corStatus(StatusConsulta status) {
    switch (status) {
      case StatusConsulta.agendada: return Colors.orange;
      case StatusConsulta.confirmada: return Colors.green;
      case StatusConsulta.cancelada: return Colors.red;
      case StatusConsulta.realizada: return Colors.grey;
    }
  }

  String _labelStatus(StatusConsulta s) {
    switch (s) {
      case StatusConsulta.agendada: return 'Agendada';
      case StatusConsulta.confirmada: return 'Confirmada';
      case StatusConsulta.cancelada: return 'Cancelada';
      case StatusConsulta.realizada: return 'Realizada';
    }
  }

  void _alterarStatus(Consulta consulta) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alterar status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...StatusConsulta.values.map((s) => ListTile(
                  leading: CircleAvatar(radius: 8, backgroundColor: _corStatus(s)),
                  title: Text(_labelStatus(s)),
                  onTap: () async {
                    await ConsultaService.atualizarStatus(consulta.id, s);
                    if (mounted) Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _registrarEvolucao(Consulta consulta) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.notes, color: Color(0xFF7C6FCD)),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'Evolução — ${consulta.pacienteNome.split(' ').first}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 4),
            Text(DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(consulta.dataHora),
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 6,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Escreva as anotações da sessão...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF7C6FCD), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  final nova = Evolucao(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    pacienteId: consulta.pacienteId,
                    pacienteNome: consulta.pacienteNome,
                    data: consulta.dataHora,
                    anotacao: controller.text.trim(),
                    consultaId: consulta.id,
                  );
                  await EvolucaoService.salvar(nova);
                  await ConsultaService.atualizarStatus(
                      consulta.id, StatusConsulta.realizada);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Evolução de ${consulta.pacienteNome.split(' ').first} registrada!'),
                      backgroundColor: Colors.green,
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C6FCD),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Salvar evolução', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Consulta>>(
      stream: ConsultaService.listar(),
      builder: (context, snapshot) {
        _todasConsultas = snapshot.data ?? [];
        final consultasDoDia = _consultasDoDia(_selectedDay ?? DateTime.now());

        return Scaffold(
          appBar: AppBar(
            title: const Text('Agenda'),
            actions: [
              IconButton(
                icon: const Icon(Icons.today),
                onPressed: () => setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = DateTime.now();
                }),
              ),
            ],
          ),
          body: Column(
            children: [
              TableCalendar(
                locale: 'pt_BR',
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                onDaySelected: (selected, focused) => setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                }),
                eventLoader: (day) => _todasConsultas
                    .where((c) => isSameDay(c.dataHora, day))
                    .toList(),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                      color: const Color(0xFF7C6FCD).withOpacity(0.4),
                      shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(
                      color: Color(0xFF7C6FCD), shape: BoxShape.circle),
                  markerDecoration: const BoxDecoration(
                      color: Color(0xFF7C6FCD), shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(
                    formatButtonVisible: false, titleCentered: true),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      DateFormat("EEEE, d 'de' MMMM", 'pt_BR')
                          .format(_selectedDay ?? DateTime.now()),
                      style: const TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 14, color: Color(0xFF7C6FCD)),
                    ),
                    const Spacer(),
                    Text('${consultasDoDia.length} consulta(s)',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              Expanded(
                child: consultasDoDia.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.event_available, size: 52, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Nenhuma consulta neste dia',
                            style: TextStyle(color: Colors.grey[400])),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: consultasDoDia.length,
                        itemBuilder: (_, i) {
                          final c = consultasDoDia[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFF7C6FCD).withOpacity(0.1),
                                      child: Text(
                                        c.pacienteNome.split(' ').first[0].toUpperCase(),
                                        style: const TextStyle(color: Color(0xFF7C6FCD),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.pacienteNome,
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Text(
                                          '${DateFormat('HH:mm').format(c.dataHora)} • ${c.duracaoMinutos} min',
                                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                        ),
                                      ],
                                    )),
                                    GestureDetector(
                                      onTap: () => _alterarStatus(c),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _corStatus(c.status).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(c.statusLabel,
                                            style: TextStyle(color: _corStatus(c.status),
                                                fontSize: 12, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ]),
                                  if (c.status != StatusConsulta.cancelada) ...[
                                    const SizedBox(height: 10),
                                    const Divider(height: 1),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => _registrarEvolucao(c),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            c.status == StatusConsulta.realizada
                                                ? Icons.check_circle
                                                : Icons.notes_outlined,
                                            size: 16,
                                            color: c.status == StatusConsulta.realizada
                                                ? Colors.green
                                                : const Color(0xFF7C6FCD),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            c.status == StatusConsulta.realizada
                                                ? 'Sessão registrada — adicionar nota'
                                                : 'Registrar evolução',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: c.status == StatusConsulta.realizada
                                                  ? Colors.green
                                                  : const Color(0xFF7C6FCD),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Deletar consulta'),
                                          content: Text('Deseja deletar a consulta de ${c.pacienteNome.split(' ').first}?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancelar')),
                                            TextButton(
                                              onPressed: () async {
                                                await ConsultaService.deletar(c.id);
                                                if (mounted) Navigator.pop(context);
                                              },
                                              child: const Text('Deletar',
                                                  style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                          SizedBox(width: 6),
                                          Text('Deletar consulta',
                                              style: TextStyle(fontSize: 13,
                                                  color: Colors.red, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final nova = await Navigator.push<Consulta>(
                context,
                MaterialPageRoute(builder: (_) => NovaConsultaScreen(
                    diaSelecionado: _selectedDay ?? DateTime.now())),
              );
              if (nova != null) {
                await ConsultaService.salvar(nova);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Nova consulta'),
          ),
        );
      },
    );
  }
}