class Paciente {
  final String id;
  final String nome;
  final String telefone;
  final String email;
  final DateTime dataNascimento;
  final String observacoes;

  Paciente({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.email,
    required this.dataNascimento,
    this.observacoes = '',
  });

  int get idade {
    final hoje = DateTime.now();
    int anos = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      anos--;
    }
    return anos;
  }

  String get iniciais {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
    }
    return partes.first[0].toUpperCase();
  }
}
