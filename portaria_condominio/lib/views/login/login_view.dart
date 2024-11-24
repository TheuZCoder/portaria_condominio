import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _hasCredentials = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadSavedEmail();
    await _checkBiometricAvailability();
    await _loadBiometricPreference();
    await _checkSavedCredentials();
  }

  Future<void> _checkSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    setState(() {
      _hasCredentials = savedEmail != null && savedPassword != null;
    });
  }

  Future<void> _loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
    });
    
    // Se a biometria estiver habilitada e tiver credenciais salvas, tenta autenticar
    if (_isBiometricEnabled && _isBiometricAvailable && _hasCredentials) {
      await _authenticateWithBiometrics();
    }
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
      });
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported;
      });
    } catch (e) {
      debugPrint('Erro ao verificar biometria: $e');
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  Future<void> _saveCredentials() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Preencha email e senha antes de habilitar a biometria';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('password', _passwordController.text.trim());
    setState(() {
      _hasCredentials = true;
    });
  }

  Future<void> _toggleBiometric(bool? value) async {
    if (value == null) return;

    final prefs = await SharedPreferences.getInstance();
    
    if (value) {
      // Se está habilitando a biometria
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Faça login primeiro antes de habilitar a biometria';
        });
        return;
      }
      await _saveCredentials();
    } else {
      // Se está desabilitando a biometria, remove as credenciais
      await prefs.remove('password');
      setState(() {
        _hasCredentials = false;
      });
    }

    await prefs.setBool('isBiometricEnabled', value);
    setState(() {
      _isBiometricEnabled = value;
      _errorMessage = '';
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      if (!_isBiometricAvailable) {
        setState(() {
          _errorMessage = 'Biometria não disponível neste dispositivo';
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email');
      final savedPassword = prefs.getString('password');

      if (savedEmail == null || savedPassword == null) {
        setState(() {
          _errorMessage = 'Credenciais não encontradas. Faça login primeiro';
          _hasCredentials = false;
        });
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Autentique-se para acessar o aplicativo',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        await _handleLogin(savedEmail, savedPassword);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro na autenticação biométrica: $e';
      });
    }
  }

  Future<void> _handleLogin([String? email, String? password]) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userEmail = email ?? _emailController.text.trim();
      final userPassword = password ?? _passwordController.text.trim();

      if (userEmail.isEmpty || userPassword.isEmpty) {
        setState(() {
          _errorMessage = 'Preencha todos os campos';
          _isLoading = false;
        });
        return;
      }

      final role = await _authController.signIn(userEmail, userPassword);

      // Salvar email sempre
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', userEmail);
      
      // Se biometria estiver habilitada, salva a senha também
      if (_isBiometricEnabled) {
        await prefs.setString('password', userPassword);
        setState(() {
          _hasCredentials = true;
        });
      }

      if (role == 'morador' || role == 'portaria') {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          _errorMessage = 'Usuário não reconhecido';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao fazer login: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
            Center(
              child: Image.asset(
                'assets/img/logo.png',
                height: 250,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: appLocalizations.translate('username'),
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: appLocalizations.translate('password'),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            if (_isBiometricAvailable) ...[
              CheckboxListTile(
                title: const Text('Habilitar login com biometria'),
                value: _isBiometricEnabled,
                onChanged: _toggleBiometric,
              ),
              if (_isBiometricEnabled && _hasCredentials) ...[
                const SizedBox(height: 8),
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.fingerprint, size: 40),
                    onPressed: _authenticateWithBiometrics,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () => _handleLogin(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(appLocalizations.translate('login_button')),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
