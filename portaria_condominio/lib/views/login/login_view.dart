import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../localizations/app_localizations.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = AuthController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('login_title')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo da empresa
            Center(
              child: Image.asset(
                'assets/img/logo.png', // Substitua pelo caminho do logo
                height: 250,
              ),
            ),
            const SizedBox(height: 32),
            // Campo de email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: appLocalizations.translate('username'),
              ),
            ),
            const SizedBox(height: 16),
            // Campo de senha
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: appLocalizations.translate('password'),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Botão de Login
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text(appLocalizations.translate('login_button')),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final role = await _authController.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (role == 'morador') {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (role == 'portaria') {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não reconhecido.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
