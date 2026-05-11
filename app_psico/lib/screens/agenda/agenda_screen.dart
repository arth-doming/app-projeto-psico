import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../data/dados_locais.dart';
import '../../models/consulta.dart';
import 'nova_consulta_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late List<Consulta> _todasConsultas;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _todasConsultas = List.from(consultasLocais);
  }

  List<Consulta> _consultasDoDia(DateTime dia) {
    return _todasConsultas.where((c) => isSameDay(c.dataHora, dia)).toList()
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));
  }

  List<DateTime> _diasComConsulta() {
    return _todasConsultas.map((c) => DateUtils.dateOnly(c.dataHora)).toList();
  }

  Color _corStatus(StatusConsulta status) {
    switch (status) {
      case StatusConsulta.agendada:
        return Colors.orange;
      case StatusConsulta.confirmada:
        return Colors.green;
      case StatusConsulta.cancelada:
        return Colors.red;
      case StatusConsulta.realizada:
        return Colors.grey;
    }
  }

  void _alterarStatus(Consulta consulta) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alterar status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...StatusConsulta.values.map((s) => ListTile(
                  leading: CircleAvatar(
                    radius: 8,
                    backgroundColor: _corStatus(s),
                  ),
                  title: Text(_labelStatus(s)),
                  onTap: () {
                    setState(() => consulta.status = s);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  String _labelStatus(StatusConsulta s) {
    switch (s) {
      case StatusConsulta.agendada:
        return 'Agendada';
      case StatusConsulta.confirmada:
        return 'Confirmada';
      case StatusConsulta.cancelada:
        return 'Cancelada';
      case StatusConsulta.realizada:
        return 'Realizada';
    }
  }

  @override
  Widget build(BuildContext context) {
    final consultasDoDia = _consultasDoDia(_selectedDay ?? DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Hoje',
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
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: (day) => _diasComConsulta()
                .where((d) => isSameDay(d, day))
                .map((_) => true)
                .toList(),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: const Color(0xFF7C6FCD).withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF7C6FCD),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Color(0xFF7C6FCD),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  DateFormat("EEEE, d 'de' MMMM", 'pt_BR')
                      .format(_selectedDay ?? DateTime.now()),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF7C6FCD),
                  ),
                ),
                const Spacer(),
                Text(
                  '${consultasDoDia.length} consulta(s)',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: consultasDoDia.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_available,
                            size: 52, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Nenhuma consulta neste dia',
                            style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: consultasDoDia.length,
                    itemBuilder: (_, i) {
                      final c = consultasDoDia[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFF7C6FCD).withOpacity(0.1),
                            child: Text(
                              c.pacienteNome.split(' ').first[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Color(0xFF7C6FCD),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(c.pacienteNome,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              DateFormat('HH:mm').format(c.dataHora) +
                                  ' • ${c.duracaoMinutos} min'),
                          trailing: GestureDetector(
                            onTap: () => _alterarStatus(c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _corStatus(c.status).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                c.statusLabel,
                                style: TextStyle(
                                  color: _corStatus(c.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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
            MaterialPageRoute(
                builder: (_) => NovaConsultaScreen(
                    diaSelecionado: _selectedDay ?? DateTime.now())),
          );
          if (nova != null) {
            setState(() => _todasConsultas.add(nova));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova consulta'),
      ),
    );
  }
}
