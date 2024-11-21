import 'package:flutter/material.dart';
import '../../localizations/app_localizations.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

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
                'assets/logo.png', // Substitua pelo caminho do logo
                height: 120,
              ),
            ),
            const SizedBox(height: 32),
            // Campo de username
            TextField(
              decoration: InputDecoration(
                labelText: appLocalizations.translate('username'),
              ),
            ),
            const SizedBox(height: 16),
            // Campo de senha
            TextField(
              decoration: InputDecoration(
                labelText: appLocalizations.translate('password'),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Botões Lembrar email e ativar biometria
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para lembrar email
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Lembrar Email'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para ativar biometria
                  },
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Biometria'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Botão de Login
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              child: Text(appLocalizations.translate('login_button')),
            ),
            const SizedBox(height: 16),
            // Botão de autenticação com Google
            ElevatedButton.icon(
              onPressed: () {
                // Lógica de autenticação com Google
              },
              icon: const Icon(Icons.g_mobiledata, size: 30),
              label: const Text('Entrar com Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Mensagem "Ainda não possui cadastro?"
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text.rich(
                  TextSpan(
                    text: 'Ainda não possui cadastro? ',
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Crie uma conta',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
