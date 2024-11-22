// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api, camel_case_types, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class exemplo extends StatefulWidget {
  @override
  _exemplo_state createState() => _exemplo_state();
}

class _exemplo_state extends State<exemplo> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  String _errorMessage = '';

  // Função de login com email e senha
  Future<void> _loginWithEmailAndPassword() async {
    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Preencha ambos os campos.';
        });
        return;
      }

      // Tenta autenticar com Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Salvar as credenciais no SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', _emailController.text);
      prefs.setString('password', _passwordController.text);

      print('Login com email e senha bem-sucedido!');
      // Verificar se a biometria está vinculada
      bool isBiometricLinked = prefs.getBool('isBiometricLinked') ?? false;
      if (isBiometricLinked) {
        // Autenticar com biometria
        _loginWithBiometric();
      } else {
        // Navegar para a tela principal
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Erro ao fazer login: $e');
      setState(() {
        _errorMessage = 'Erro ao fazer login com email e senha.';
      });
    }
  }

  // Função para login com biometria
  Future<void> _loginWithBiometric() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? '';
      String password = prefs.getString('password') ?? '';

      if (email.isEmpty || password.isEmpty) {
        print('Email ou senha não encontrados.');
        return;
      }

      bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      if (!canAuthenticateWithBiometrics) {
        _showErrorDialog('Biometria não está disponível neste dispositivo.');
        return;
      }

      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Por favor, autentique-se para entrar',
        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      if (authenticated) {
        print('Autenticação biométrica realizada.');
        // Autenticação bem-sucedida com biometria, logar no Firebase
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog('Falha na autenticação biométrica.');
      }
    } catch (e) {
      print('Erro na autenticação biométrica: $e');
      _showErrorDialog('Erro ao tentar autenticar com biometria.');
    }
  }

  // Função para exibir um diálogo de erro
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.black, // AppBar com fundo preto
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.white), // Texto branco
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // Borda branca
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber), // Borda dourada
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white), // Texto branco
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: const TextStyle(color: Colors.white), // Texto branco
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // Borda branca
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber), // Borda dourada
                ),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white), // Texto branco
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithEmailAndPassword,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.amber, // Texto preto no botão
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Entrar com Email e Senha'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithBiometric,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.amber, // Texto preto no botão
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Entrar com Biometria'),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => RegisterScreen()),
                // );
              },
              child: const Text(
                'Não tem uma conta? Registre-se aqui',
                style: TextStyle(color: Colors.amber), // Texto dourado
              ),
            ),
          ],
        ),
      ),
    );
  }
}