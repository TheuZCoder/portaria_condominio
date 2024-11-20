import 'package:flutter/material.dart';
import 'package:portaria_condominio/controllers/morador_controller.dart';

import '../../models/morador_model.dart';

class CadastroMoradoresView extends StatefulWidget {
  const CadastroMoradoresView({super.key});

  @override
  State<CadastroMoradoresView> createState() => _CadastroMoradoresViewState();
}

class _CadastroMoradoresViewState extends State<CadastroMoradoresView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = MoradorController();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Morador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nomeController,
                label: 'Nome',
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              _buildTextField(
                controller: _cpfController,
                label: 'CPF',
                validator: (value) => value!.isEmpty ? 'Informe o CPF' : null,
              ),
              _buildTextField(
                controller: _telefoneController,
                label: 'Telefone',
                validator: (value) =>
                    value!.isEmpty ? 'Informe o telefone' : null,
              ),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Informe o email' : null,
              ),
              _buildTextField(
                controller: _senhaController,
                label: 'Senha',
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'A senha deve ter pelo menos 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Cadastrar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final novoMorador = Morador(
          id: '', // Será gerado automaticamente pelo Firestore
          nome: _nomeController.text.trim(),
          cpf: _cpfController.text.trim(),
          telefone: _telefoneController.text.trim(),
          email: _emailController.text.trim(),
          senha: _senhaController.text.trim(),
        );

        await _controller.criarMorador(novoMorador);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Morador cadastrado com sucesso!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
