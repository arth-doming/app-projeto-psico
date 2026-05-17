import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/paciente.dart';
import '../../data/dados_locais.dart';

class PacienteFormScreen extends StatefulWidget {
  final Paciente? paciente;
  const PacienteFormScreen({super.key, this.paciente});

  @override
  State<PacienteFormScreen> createState() => _PacienteFormScreenState();
}

class _PacienteFormScreenState extends State<PacienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _observacoesController;
  DateTime? _dataNascimento;

  bool get _editando => widget.paciente != null;

  @override
  void initState() {
    super.initState();
    _nomeController =
        TextEditingController(text: widget.paciente?.nome ?? '');
    _telefoneController =
        TextEditingController(text: widget.paciente?.telefone ?? '');
    _emailController =
        TextEditingController(text: widget.paciente?.email ?? '');
    _observacoesController =
        TextEditingController(text: widget.paciente?.observacoes ?? '');
    _dataNascimento = widget.paciente?.dataNascimento;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) setState(() => _dataNascimento = picked);
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento')),
      );
      return;
    }

    if (_editando) {
      final index =
          pacientesLocais.indexWhere((p) => p.id == widget.paciente!.id);
      if (index != -1) {
        final atualizado = Paciente(
          id: widget.paciente!.id,
          nome: _nomeController.text.trim(),
          telefone: _telefoneController.text.trim(),
          email: _emailController.text.trim(),
          dataNascimento: _dataNascimento!,
          observacoes: _observacoesController.text.trim(),
        );
        pacientesLocais[index] = atualizado;
        Navigator.pop(context, atualizado);
      }
    } else {
      final novo = Paciente(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text.trim(),
        telefone: _telefoneController.text.trim(),
        email: _emailController.text.trim(),
        dataNascimento: _dataNascimento!,
        observacoes: _observacoesController.text.trim(),
      );
      pacientesLocais.add(novo);
      Navigator.pop(context, novo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar paciente' : 'Novo paciente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 38,
                backgroundColor:
                    const Color(0xFF7C6FCD).withOpacity(0.15),
                child: _editando
                    ? Text(
                        widget.paciente!.iniciais,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C6FCD)),
                      )
                    : const Icon(Icons.person,
                        size: 40, color: Color(0xFF7C6FCD)),
              ),
            ),
            const SizedBox(height: 28),
            _campo(
              controller: _nomeController,
              label: 'Nome completo',
              icon: Icons.person_outline,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            _campo(
              controller: _telefoneController,
              label: 'Telefone',
              icon: Icons.phone_outlined,
              tipo: TextInputType.phone,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Informe o telefone' : null,
            ),
            const SizedBox(height: 16),
            _campo(
              controller: _emailController,
              label: 'E-mail',
              icon: Icons.email_outlined,
              tipo: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Informe o e-mail' : null,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selecionarData,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake_outlined,
                        color: Color(0xFF7C6FCD)),
                    const SizedBox(width: 12),
                    Text(
                      _dataNascimento == null
                          ? 'Data de nascimento'
                          : DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR')
                              .format(_dataNascimento!),
                      style: TextStyle(
                        fontSize: 16,
                        color: _dataNascimento == null
                            ? Colors.grey[600]
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _campo(
              controller: _observacoesController,
              label: 'Observações (opcional)',
              icon: Icons.notes_outlined,
              maxLinhas: 4,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C6FCD),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _editando ? 'Salvar alterações' : 'Cadastrar paciente',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType tipo = TextInputType.text,
    String? Function(String?)? validator,
    int maxLinhas = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: tipo,
      maxLines: maxLinhas,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF7C6FCD)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF7C6FCD), width: 2),
        ),
      ),
    );
  }
}