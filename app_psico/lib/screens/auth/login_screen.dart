import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  bool _verSenha = false;
  bool _modoCadastro = false;
  String? _erro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      if (_modoCadastro) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _erro = _mensagemErro(e.code));
    } finally {
      setState(() => _carregando = false);
    }
  }

  String _mensagemErro(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Nenhuma conta encontrada com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      default:
        return 'Erro ao entrar. Tente novamente.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C6FCD),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C6FCD).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Agenda Psicóloga',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _modoCadastro
                      ? 'Crie sua conta para começar'
                      : 'Entre na sua conta',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 36),

                // Campo e-mail
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Informe o e-mail'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon:
                        const Icon(Icons.email_outlined,
                            color: Color(0xFF7C6FCD)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF7C6FCD), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Campo senha
                TextFormField(
                  controller: _senhaController,
                  obscureText: !_verSenha,
                  validator: (v) => v == null || v.length < 6
                      ? 'Senha deve ter ao menos 6 caracteres'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon:
                        const Icon(Icons.lock_outlined,
                            color: Color(0xFF7C6FCD)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _verSenha
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _verSenha = !_verSenha),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF7C6FCD), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                // Erro
                if (_erro != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _erro!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Botão principal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _entrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C6FCD),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _carregando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _modoCadastro ? 'Criar conta' : 'Entrar',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Alternar entre login e cadastro
                TextButton(
                  onPressed: () => setState(() {
                    _modoCadastro = !_modoCadastro;
                    _erro = null;
                  }),
                  child: Text(
                    _modoCadastro
                        ? 'Já tem uma conta? Entrar'
                        : 'Não tem conta? Cadastre-se',
                    style: const TextStyle(color: Color(0xFF7C6FCD)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}